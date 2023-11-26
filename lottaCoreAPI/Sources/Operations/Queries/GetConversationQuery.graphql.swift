// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetConversationQuery: GraphQLQuery {
  public static let operationName: String = "GetConversationQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetConversationQuery($id: ID!, $markAsRead: Boolean) { conversation(id: $id, markAsRead: $markAsRead) { __typename id updatedAt unreadMessages groups { __typename id name } users { __typename id name nickname avatarImageFile { __typename id } } messages { __typename id content insertedAt updatedAt files { __typename id filename fileType filesize } user { __typename id name nickname avatarImageFile { __typename id } } } } }"#
    ))

  public var id: ID
  public var markAsRead: GraphQLNullable<Bool>

  public init(
    id: ID,
    markAsRead: GraphQLNullable<Bool>
  ) {
    self.id = id
    self.markAsRead = markAsRead
  }

  public var __variables: Variables? { [
    "id": id,
    "markAsRead": markAsRead
  ] }

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootQueryType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("conversation", Conversation?.self, arguments: [
        "id": .variable("id"),
        "markAsRead": .variable("markAsRead")
      ]),
    ] }

    public var conversation: Conversation? { __data["conversation"] }

    /// Conversation
    ///
    /// Parent Type: `Conversation`
    public struct Conversation: LottaCoreAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.Conversation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", LottaCoreAPI.ID?.self),
        .field("updatedAt", LottaCoreAPI.DateTime?.self),
        .field("unreadMessages", Int?.self),
        .field("groups", [Group]?.self),
        .field("users", [User]?.self),
        .field("messages", [Message]?.self),
      ] }

      public var id: LottaCoreAPI.ID? { __data["id"] }
      public var updatedAt: LottaCoreAPI.DateTime? { __data["updatedAt"] }
      public var unreadMessages: Int? { __data["unreadMessages"] }
      public var groups: [Group]? { __data["groups"] }
      public var users: [User]? { __data["users"] }
      public var messages: [Message]? { __data["messages"] }

      /// Conversation.Group
      ///
      /// Parent Type: `UserGroup`
      public struct Group: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.UserGroup }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
          .field("name", String?.self),
        ] }

        public var id: LottaCoreAPI.ID? { __data["id"] }
        public var name: String? { __data["name"] }
      }

      /// Conversation.User
      ///
      /// Parent Type: `User`
      public struct User: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
          .field("name", String?.self),
          .field("nickname", String?.self),
          .field("avatarImageFile", AvatarImageFile?.self),
        ] }

        public var id: LottaCoreAPI.ID? { __data["id"] }
        public var name: String? { __data["name"] }
        public var nickname: String? { __data["nickname"] }
        public var avatarImageFile: AvatarImageFile? { __data["avatarImageFile"] }

        /// Conversation.User.AvatarImageFile
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

      /// Conversation.Message
      ///
      /// Parent Type: `Message`
      public struct Message: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.Message }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
          .field("content", String?.self),
          .field("insertedAt", LottaCoreAPI.DateTime?.self),
          .field("updatedAt", LottaCoreAPI.DateTime?.self),
          .field("files", [File?]?.self),
          .field("user", User?.self),
        ] }

        public var id: LottaCoreAPI.ID? { __data["id"] }
        public var content: String? { __data["content"] }
        public var insertedAt: LottaCoreAPI.DateTime? { __data["insertedAt"] }
        public var updatedAt: LottaCoreAPI.DateTime? { __data["updatedAt"] }
        public var files: [File?]? { __data["files"] }
        public var user: User? { __data["user"] }

        /// Conversation.Message.File
        ///
        /// Parent Type: `File`
        public struct File: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID?.self),
            .field("filename", String?.self),
            .field("fileType", GraphQLEnum<LottaCoreAPI.FileType>?.self),
            .field("filesize", Int?.self),
          ] }

          public var id: LottaCoreAPI.ID? { __data["id"] }
          public var filename: String? { __data["filename"] }
          public var fileType: GraphQLEnum<LottaCoreAPI.FileType>? { __data["fileType"] }
          public var filesize: Int? { __data["filesize"] }
        }

        /// Conversation.Message.User
        ///
        /// Parent Type: `User`
        public struct User: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID?.self),
            .field("name", String?.self),
            .field("nickname", String?.self),
            .field("avatarImageFile", AvatarImageFile?.self),
          ] }

          public var id: LottaCoreAPI.ID? { __data["id"] }
          public var name: String? { __data["name"] }
          public var nickname: String? { __data["nickname"] }
          public var avatarImageFile: AvatarImageFile? { __data["avatarImageFile"] }

          /// Conversation.Message.User.AvatarImageFile
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
  }
}
