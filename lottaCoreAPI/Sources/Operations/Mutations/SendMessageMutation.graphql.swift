// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SendMessageMutation: GraphQLMutation {
  public static let operationName: String = "SendMessage"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation SendMessage($message: MessageInput!) { message: createMessage(message: $message) { __typename id content insertedAt updatedAt user { __typename id name nickname avatarImageFile { __typename id } } files { __typename id } conversation { __typename id insertedAt updatedAt users { __typename id } groups { __typename id } messages { __typename id } } } }"#
    ))

  public var message: MessageInput

  public init(message: MessageInput) {
    self.message = message
  }

  public var __variables: Variables? { ["message": message] }

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootMutationType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createMessage", alias: "message", Message?.self, arguments: ["message": .variable("message")]),
    ] }

    public var message: Message? { __data["message"] }

    /// Message
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
        .field("user", User?.self),
        .field("files", [File?]?.self),
        .field("conversation", Conversation?.self),
      ] }

      public var id: LottaCoreAPI.ID? { __data["id"] }
      public var content: String? { __data["content"] }
      public var insertedAt: LottaCoreAPI.DateTime? { __data["insertedAt"] }
      public var updatedAt: LottaCoreAPI.DateTime? { __data["updatedAt"] }
      public var user: User? { __data["user"] }
      public var files: [File?]? { __data["files"] }
      public var conversation: Conversation? { __data["conversation"] }

      /// Message.User
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

        /// Message.User.AvatarImageFile
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

      /// Message.File
      ///
      /// Parent Type: `File`
      public struct File: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
        ] }

        public var id: LottaCoreAPI.ID? { __data["id"] }
      }

      /// Message.Conversation
      ///
      /// Parent Type: `Conversation`
      public struct Conversation: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.Conversation }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
          .field("insertedAt", LottaCoreAPI.DateTime?.self),
          .field("updatedAt", LottaCoreAPI.DateTime?.self),
          .field("users", [User]?.self),
          .field("groups", [Group]?.self),
          .field("messages", [Message]?.self),
        ] }

        public var id: LottaCoreAPI.ID? { __data["id"] }
        public var insertedAt: LottaCoreAPI.DateTime? { __data["insertedAt"] }
        public var updatedAt: LottaCoreAPI.DateTime? { __data["updatedAt"] }
        public var users: [User]? { __data["users"] }
        public var groups: [Group]? { __data["groups"] }
        public var messages: [Message]? { __data["messages"] }

        /// Message.Conversation.User
        ///
        /// Parent Type: `User`
        public struct User: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID?.self),
          ] }

          public var id: LottaCoreAPI.ID? { __data["id"] }
        }

        /// Message.Conversation.Group
        ///
        /// Parent Type: `UserGroup`
        public struct Group: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.UserGroup }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID?.self),
          ] }

          public var id: LottaCoreAPI.ID? { __data["id"] }
        }

        /// Message.Conversation.Message
        ///
        /// Parent Type: `Message`
        public struct Message: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.Message }
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
