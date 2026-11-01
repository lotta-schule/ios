//
//  MockBackend.swift
//  lottaTests
//
//  An in-process fake of the lotta core-api, served through a URLProtocol,
//  so that auth flows can be tested without network access.
//

import Foundation

/// Builds unsigned JWTs. JWTDecode does not verify signatures, so this is all the app needs.
enum JWTFactory {
    static func make(
        typ: String,
        sub: String = MockBackend.userId,
        tid: Int = Int(MockBackend.tenantId)!,
        expiresIn: TimeInterval = 3600,
        nonce: String = UUID().uuidString
    ) -> String {
        let header: [String: Any] = ["alg": "HS512", "typ": "JWT"]
        let now = Int(Date().timeIntervalSince1970)
        let payload: [String: Any] = [
            "aud": "lotta",
            "iss": "lotta",
            "typ": typ,
            "sub": sub,
            "tid": tid,
            "iat": now,
            "exp": now + Int(expiresIn),
            "jti": nonce,
        ]
        return [header, payload]
            .map { base64url(try! JSONSerialization.data(withJSONObject: $0)) }
            .joined(separator: ".") + "." + base64url(Data("signature".utf8))
    }

    private static func base64url(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

struct MockResponse {
    var status: Int = 200
    var json: Any? = nil
    var headers: [String: String] = [:]
    /// When set, the request fails with this error instead of returning a response.
    var error: URLError? = nil

    static func failure(_ code: URLError.Code) -> MockResponse {
        MockResponse(error: URLError(code))
    }
}

struct RecordedRequest {
    let path: String
    let query: [URLQueryItem]
    let headers: [String: String]
    /// GraphQL operation name, for requests to /api
    let operationName: String?
}

/// Shared state of the fake backend. Tests run serialized, so plain static state is fine.
enum MockBackend {
    static let tenantId = "1"
    static let tenantSlug = "test"
    static let userId = "42"

    static var requests: [RecordedRequest] = []

    /// Handler for POST /auth/token/refresh. The default mirrors the current backend
    /// (`LottaWeb.SessionJSON.refresh/1`): only `accessToken` in the body,
    /// the new refresh token is only sent as a cookie.
    static var refreshHandler: (RecordedRequest) -> MockResponse = { _ in currentBackendRefresh() }

    /// Handler for GraphQL requests to /api.
    static var graphqlHandler: (RecordedRequest) -> MockResponse = { defaultGraphQL($0) }

    static func reset() {
        requests = []
        refreshHandler = { _ in currentBackendRefresh() }
        graphqlHandler = { defaultGraphQL($0) }
    }

    static func requests(forOperation name: String) -> [RecordedRequest] {
        requests.filter { $0.operationName == name }
    }

    static func requests(forPath path: String) -> [RecordedRequest] {
        requests.filter { $0.path == path }
    }

    // MARK: - Canned responses

    static func cookieHeaders(refreshToken: String?, accessToken: String?) -> [String: String] {
        let cookies = [
            refreshToken.map { "SignInRefreshToken=\($0); path=/; max-age=1814400; HttpOnly; SameSite=Lax" },
            accessToken.map { "SignInAccessToken=\($0); path=/; max-age=1814400; HttpOnly; SameSite=Lax" },
        ].compactMap { $0 }
        return cookies.isEmpty ? [:] : ["Set-Cookie": cookies.joined(separator: ", ")]
    }

    static func currentBackendRefresh() -> MockResponse {
        let accessToken = JWTFactory.make(typ: "access")
        let refreshToken = JWTFactory.make(typ: "refresh", expiresIn: 4 * 7 * 24 * 3600)
        return MockResponse(
            json: ["success": true, "accessToken": accessToken],
            headers: cookieHeaders(refreshToken: refreshToken, accessToken: accessToken)
        )
    }

    static func legacyBackendRefresh() -> MockResponse {
        let accessToken = JWTFactory.make(typ: "access")
        let refreshToken = JWTFactory.make(typ: "refresh", expiresIn: 4 * 7 * 24 * 3600)
        return MockResponse(
            json: ["success": true, "accessToken": accessToken, "refreshToken": refreshToken],
            headers: cookieHeaders(refreshToken: refreshToken, accessToken: accessToken)
        )
    }

    static func defaultGraphQL(_ request: RecordedRequest) -> MockResponse {
        switch request.operationName {
        case "GetTenant":
            return MockResponse(json: ["data": ["tenant": tenantFixture]])
        case "Login":
            let accessToken = JWTFactory.make(typ: "access")
            let refreshToken = JWTFactory.make(typ: "refresh", expiresIn: 4 * 7 * 24 * 3600)
            return MockResponse(
                json: ["data": ["login": [
                    "__typename": "Authresult",
                    "accessToken": accessToken,
                    "refreshToken": refreshToken,
                ]]],
                headers: cookieHeaders(refreshToken: refreshToken, accessToken: accessToken)
            )
        case "GetCurrentUser":
            return MockResponse(json: ["data": ["currentUser": currentUserFixture]])
        case "GetConversations":
            return MockResponse(json: ["data": ["conversations": []]])
        default:
            return MockResponse(json: ["data": NSNull()])
        }
    }

    static var tenantFixture: [String: Any] {
        [
            "__typename": "Tenant",
            "id": tenantId,
            "title": "Test School",
            "slug": tenantSlug,
            "host": "\(tenantSlug).lotta.schule",
            "configuration": [
                "__typename": "TenantConfiguration",
                "backgroundImageFile": NSNull(),
                "logoImageFile": NSNull(),
                "customTheme": NSNull(),
                "userMaxStorageConfig": NSNull(),
            ] as [String: Any],
        ]
    }

    static var currentUserFixture: [String: Any] {
        [
            "__typename": "User",
            "id": userId,
            "insertedAt": "2024-01-01T00:00:00Z",
            "updatedAt": "2024-01-01T00:00:00Z",
            "lastSeen": NSNull(),
            "name": "Test User",
            "nickname": NSNull(),
            "email": "test@lotta.schule",
            "class": NSNull(),
            "hideFullName": false,
            "enrollmentTokens": [],
            "unreadMessages": 0,
            "hasChangedDefaultPassword": true,
            "avatarImageFile": NSNull(),
            "groups": [],
        ]
    }
}

final class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}

    override func startLoading() {
        guard let url = request.url else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let body = Self.readBody(of: request)
        let operationName = body
            .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }?["operationName"] as? String

        let recorded = RecordedRequest(
            path: url.path(),
            query: components?.queryItems ?? [],
            headers: request.allHTTPHeaderFields ?? [:],
            operationName: operationName
        )

        let response: MockResponse = DispatchQueue.main.sync {
            MockBackend.requests.append(recorded)
            switch recorded.path {
            case "/auth/token/refresh":
                return MockBackend.refreshHandler(recorded)
            case "/api":
                return MockBackend.graphqlHandler(recorded)
            default:
                return MockResponse(status: 404, json: ["error": "not found"])
            }
        }

        if let error = response.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        var headers = response.headers
        headers["Content-Type"] = "application/json"
        let httpResponse = HTTPURLResponse(url: url, statusCode: response.status, httpVersion: "HTTP/1.1", headerFields: headers)!
        client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
        if let json = response.json, let data = try? JSONSerialization.data(withJSONObject: json) {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    private static func readBody(of request: URLRequest) -> Data? {
        if let body = request.httpBody { return body }
        guard let stream = request.httpBodyStream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data
    }
}
