//
//  AuthPersistenceTests.swift
//  lottaTests
//
//  Makes sure a login survives an app restart, i.e. the refresh token ends up in the keychain
//  and `UserSession.readFromDisk()` restores the session.
//

import Foundation
import Testing
import JWTDecode
import KeychainSwift
@testable import lotta

@MainActor
@Suite(.serialized)
final class AuthPersistenceTests {
    nonisolated static let keychainPrefix = "lotta-tests-"

    let baseDirectory: URL
    let refreshTokenKey = "\(MockBackend.tenantId)-\(MockBackend.userId)--refresh-token"

    init() throws {
        baseDirectory = FileManager.default.temporaryDirectory
            .appending(path: "lotta-tests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        LottaEnvironment.urlSessionConfiguration = configuration
        LottaEnvironment.baseDirectory = baseDirectory
        LottaEnvironment.keychain = KeychainSwift(keyPrefix: Self.keychainPrefix)
        LottaEnvironment.connectWebSocketOnInit = false

        MockBackend.reset()
        Self.clearTestKeychain()
    }

    deinit {
        try? FileManager.default.removeItem(at: baseDirectory)
        Self.clearTestKeychain()
    }

    /// Only removes the keys written by the tests, so a developer's real simulator login stays intact.
    nonisolated static func clearTestKeychain() {
        let testKeychain = KeychainSwift(keyPrefix: keychainPrefix)
        for key in testKeychain.allKeys where key.hasPrefix(keychainPrefix) {
            testKeychain.delete(String(key.dropFirst(keychainPrefix.count)))
        }
    }

    // MARK: - Helpers

    private func login() async throws -> UserSession {
        try await UserSession.createFromCredentials(
            onTenantSlug: MockBackend.tenantSlug,
            withUsername: "test@lotta.schule",
            andPassword: "password"
        )
    }

    /// `readFromDisk()` refreshes user and tenant data in a detached Task. Wait for it so it doesn't
    /// leak into the next test.
    private func waitForBackgroundRefresh(after requestCount: Int) async {
        for _ in 0..<300 {
            let requests = MockBackend.requests.dropFirst(requestCount)
            if requests.contains(where: { $0.operationName == "GetTenant" }) { break }
            try? await Task.sleep(for: .milliseconds(10))
        }
        try? await Task.sleep(for: .milliseconds(100))
    }

    private func restoreSessions() async -> [UserSession] {
        let requestCount = MockBackend.requests.count
        let sessions = await UserSession.readFromDisk()
        if !sessions.isEmpty {
            await waitForBackgroundRefresh(after: requestCount)
        }
        return sessions
    }

    private var sessionFileURL: URL {
        baseDirectory.appendingPathComponent("usersession-\(MockBackend.tenantId)-\(MockBackend.userId).json")
    }

    // MARK: - Login persistence

    @Test("Username/password login is restored after an app restart")
    func credentialLoginPersists() async throws {
        let session = try await login()
        #expect(session.user.id == MockBackend.userId)

        let storedToken = try #require(keychain.get(refreshTokenKey), "refresh token was not saved to the keychain")
        #expect(try decode(jwt: storedToken).claim(name: "typ").string == "refresh")

        let restored = await restoreSessions()
        #expect(restored.count == 1)
        #expect(restored.first?.user.id == MockBackend.userId)
        #expect(restored.first?.tenant.id == MockBackend.tenantId)
    }

    @Test("OAuth (Eduplaces) login is restored after an app restart")
    func oauthLoginPersists() async throws {
        let authInfo = AuthInfo(
            accessToken: try decode(jwt: JWTFactory.make(typ: "access")),
            refreshToken: try decode(jwt: JWTFactory.make(typ: "refresh", expiresIn: 3600 * 24))
        )
        _ = try await UserSession.createFromAuthInfo(onTenantSlug: MockBackend.tenantSlug, withAuthInfo: authInfo)

        #expect(keychain.get(refreshTokenKey) != nil, "refresh token was not saved to the keychain")

        let restored = await restoreSessions()
        #expect(restored.count == 1)
    }

    @Test("A session restored while offline is kept")
    func offlineRestoreKeepsSession() async throws {
        _ = try await login()

        MockBackend.refreshHandler = { _ in .failure(.notConnectedToInternet) }
        MockBackend.graphqlHandler = { _ in .failure(.notConnectedToInternet) }

        let restored = await restoreSessions()
        #expect(restored.count == 1)
        #expect(keychain.get(refreshTokenKey) != nil)
        #expect(FileManager.default.fileExists(atPath: sessionFileURL.path()))
    }

    @Test("Logging out removes the refresh token from the keychain")
    func logoutRemovesRefreshToken() async throws {
        let session = try await login()
        #expect(keychain.get(refreshTokenKey) != nil)

        session.removeFromKeychain()

        #expect(keychain.get(refreshTokenKey) == nil)
    }

    // MARK: - Token renewal

    private func makeAuthInfo() throws -> (AuthInfo, String) {
        let oldRefreshToken = JWTFactory.make(typ: "refresh", expiresIn: 3600 * 24)
        return (AuthInfo(refreshToken: try decode(jwt: oldRefreshToken)), oldRefreshToken)
    }

    @Test("renew sends the refresh token and tenant id")
    func renewSendsRefreshToken() async throws {
        let (authInfo, oldRefreshToken) = try makeAuthInfo()
        _ = try await authInfo.renewAsync()

        let request = try #require(MockBackend.requests(forPath: "/auth/token/refresh").first)
        #expect(request.query.first(where: { $0.name == "token" })?.value == oldRefreshToken)
        #expect(request.headers["tenant"] == "id:\(MockBackend.tenantId)")
    }

    @Test("renew stores the refresh token from the response body")
    func renewStoresRefreshTokenFromBody() async throws {
        let (authInfo, oldRefreshToken) = try makeAuthInfo()
        var returnedRefreshToken: String?
        MockBackend.refreshHandler = { _ in
            let response = MockBackend.legacyBackendRefresh()
            returnedRefreshToken = (response.json as? [String: Any])?["refreshToken"] as? String
            return response
        }

        _ = try await authInfo.renewAsync()

        #expect(returnedRefreshToken != oldRefreshToken)
        #expect(authInfo.refreshToken?.string == returnedRefreshToken)
        #expect(keychain.get(refreshTokenKey) == returnedRefreshToken)
        #expect(authInfo.accessToken != nil)
    }

    @Test("renew stores the rotated refresh token from the Set-Cookie header")
    func renewStoresRefreshTokenFromCookie() async throws {
        let (authInfo, oldRefreshToken) = try makeAuthInfo()
        let rotatedRefreshToken = JWTFactory.make(typ: "refresh", expiresIn: 3600 * 24 * 28)
        MockBackend.refreshHandler = { _ in
            MockResponse(
                json: ["success": true, "accessToken": JWTFactory.make(typ: "access")],
                headers: MockBackend.cookieHeaders(
                    refreshToken: rotatedRefreshToken,
                    accessToken: JWTFactory.make(typ: "access")
                )
            )
        }

        _ = try await authInfo.renewAsync()

        #expect(rotatedRefreshToken != oldRefreshToken)
        #expect(authInfo.refreshToken?.string == rotatedRefreshToken)
        #expect(keychain.get(refreshTokenKey) == rotatedRefreshToken)
    }

    @Test("renew keeps the current refresh token if the server returns none")
    func renewKeepsRefreshToken() async throws {
        let (authInfo, oldRefreshToken) = try makeAuthInfo()
        MockBackend.refreshHandler = { _ in
            MockResponse(json: ["success": true, "accessToken": JWTFactory.make(typ: "access")])
        }

        _ = try await authInfo.renewAsync()

        #expect(authInfo.refreshToken?.string == oldRefreshToken)
        #expect(keychain.get(refreshTokenKey) == oldRefreshToken)
        #expect(authInfo.accessToken != nil)
    }

    @Test("renew reports a rejected refresh token as invalid")
    func renewUnauthorized() async throws {
        let (authInfo, _) = try makeAuthInfo()
        MockBackend.refreshHandler = { _ in MockResponse(status: 401, json: ["errors": ["detail": "Unauthorized"]]) }

        await #expect(throws: AuthInfo.RenewError.invalidToken) {
            try await authInfo.renewAsync()
        }
    }

    @Test("renew reports server errors as connection errors")
    func renewServerError() async throws {
        let (authInfo, _) = try makeAuthInfo()
        MockBackend.refreshHandler = { _ in MockResponse(status: 502, json: nil) }

        await #expect(throws: AuthInfo.RenewError.connectionError) {
            try await authInfo.renewAsync()
        }
    }
}
