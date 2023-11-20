// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchUsersQuery: GraphQLQuery {
  public static let operationName: String = "SearchUsers"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchUsers($searchtext: String!) { users: searchUsers(searchtext: $searchtext) { __typename id insertedAt updatedAt name class nickname avatarImageFile { __typename id } } }"#
    ))

  public var searchtext: String

  public init(searchtext: String) {
    self.searchtext = searchtext
  }

  public var __variables: Variables? { ["searchtext": searchtext] }

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootQueryType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("searchUsers", alias: "users", [User?]?.self, arguments: ["searchtext": .variable("searchtext")]),
    ] }

    public var users: [User?]? { __data["users"] }

    /// User
    ///
    /// Parent Type: `User`
    public struct User: LottaCoreAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", LottaCoreAPI.ID?.self),
        .field("insertedAt", LottaCoreAPI.DateTime?.self),
        .field("updatedAt", LottaCoreAPI.DateTime?.self),
        .field("name", String?.self),
        .field("class", String?.self),
        .field("nickname", String?.self),
        .field("avatarImageFile", AvatarImageFile?.self),
      ] }

      public var id: LottaCoreAPI.ID? { __data["id"] }
      public var insertedAt: LottaCoreAPI.DateTime? { __data["insertedAt"] }
      public var updatedAt: LottaCoreAPI.DateTime? { __data["updatedAt"] }
      public var name: String? { __data["name"] }
      public var `class`: String? { __data["class"] }
      public var nickname: String? { __data["nickname"] }
      public var avatarImageFile: AvatarImageFile? { __data["avatarImageFile"] }

      /// User.AvatarImageFile
      ///
      /// Parent Type: `File`
      public struct AvatarImageFile: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
        ] }

        public var id: LottaCoreAPI.ID? { __data["id"] }
      }
    }
  }
}
