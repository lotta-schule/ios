// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ReceiveMessageSubscription: GraphQLSubscription {
  public static let operationName: String = "ReceiveMessage"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"subscription ReceiveMessage { message: receiveMessage { __typename id content insertedAt updatedAt files { __typename id filename fileType filesize } user { __typename id name nickname avatarImageFile { __typename id formats(category: "AVATAR") { __typename name url type } } } conversation { __typename id updatedAt groups { __typename id name } users { __typename id name nickname avatarImageFile { __typename id formats(category: "AVATAR") { __typename name url type } } } unreadMessages } } }"#
    ))

  public init() {}

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootSubscriptionType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("receiveMessage", alias: "message", Message?.self),
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
        .field("id", LottaCoreAPI.ID.self),
        .field("content", String?.self),
        .field("insertedAt", LottaCoreAPI.DateTime.self),
        .field("updatedAt", LottaCoreAPI.DateTime.self),
        .field("files", [File]?.self),
        .field("user", User?.self),
        .field("conversation", Conversation.self),
      ] }

      public var id: LottaCoreAPI.ID { __data["id"] }
      public var content: String? { __data["content"] }
      public var insertedAt: LottaCoreAPI.DateTime { __data["insertedAt"] }
      public var updatedAt: LottaCoreAPI.DateTime { __data["updatedAt"] }
      public var files: [File]? { __data["files"] }
      public var user: User? { __data["user"] }
      public var conversation: Conversation { __data["conversation"] }

      /// Message.File
      ///
      /// Parent Type: `File`
      public struct File: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID.self),
          .field("filename", String.self),
          .field("fileType", GraphQLEnum<LottaCoreAPI.FileType>.self),
          .field("filesize", Int.self),
        ] }

        public var id: LottaCoreAPI.ID { __data["id"] }
        public var filename: String { __data["filename"] }
        public var fileType: GraphQLEnum<LottaCoreAPI.FileType> { __data["fileType"] }
        public var filesize: Int { __data["filesize"] }
      }

      /// Message.User
      ///
      /// Parent Type: `User`
      public struct User: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID.self),
          .field("name", String?.self),
          .field("nickname", String?.self),
          .field("avatarImageFile", AvatarImageFile?.self),
        ] }

        public var id: LottaCoreAPI.ID { __data["id"] }
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
            .field("id", LottaCoreAPI.ID.self),
            .field("formats", [Format].self, arguments: ["category": "AVATAR"]),
          ] }

          public var id: LottaCoreAPI.ID { __data["id"] }
          public var formats: [Format] { __data["formats"] }

          /// Message.User.AvatarImageFile.Format
          ///
          /// Parent Type: `AvailableFormat`
          public struct Format: LottaCoreAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.AvailableFormat }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("name", GraphQLEnum<LottaCoreAPI.ConversionFormat>.self),
              .field("url", String.self),
              .field("type", GraphQLEnum<LottaCoreAPI.FileType>.self),
            ] }

            public var name: GraphQLEnum<LottaCoreAPI.ConversionFormat> { __data["name"] }
            public var url: String { __data["url"] }
            public var type: GraphQLEnum<LottaCoreAPI.FileType> { __data["type"] }
          }
        }
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
          .field("updatedAt", LottaCoreAPI.DateTime?.self),
          .field("groups", [Group]?.self),
          .field("users", [User]?.self),
          .field("unreadMessages", Int?.self),
        ] }

        public var id: LottaCoreAPI.ID? { __data["id"] }
        public var updatedAt: LottaCoreAPI.DateTime? { __data["updatedAt"] }
        public var groups: [Group]? { __data["groups"] }
        public var users: [User]? { __data["users"] }
        public var unreadMessages: Int? { __data["unreadMessages"] }

        /// Message.Conversation.Group
        ///
        /// Parent Type: `UserGroup`
        public struct Group: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.UserGroup }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID.self),
            .field("name", String.self),
          ] }

          public var id: LottaCoreAPI.ID { __data["id"] }
          public var name: String { __data["name"] }
        }

        /// Message.Conversation.User
        ///
        /// Parent Type: `User`
        public struct User: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID.self),
            .field("name", String?.self),
            .field("nickname", String?.self),
            .field("avatarImageFile", AvatarImageFile?.self),
          ] }

          public var id: LottaCoreAPI.ID { __data["id"] }
          public var name: String? { __data["name"] }
          public var nickname: String? { __data["nickname"] }
          public var avatarImageFile: AvatarImageFile? { __data["avatarImageFile"] }

          /// Message.Conversation.User.AvatarImageFile
          ///
          /// Parent Type: `File`
          public struct AvatarImageFile: LottaCoreAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", LottaCoreAPI.ID.self),
              .field("formats", [Format].self, arguments: ["category": "AVATAR"]),
            ] }

            public var id: LottaCoreAPI.ID { __data["id"] }
            public var formats: [Format] { __data["formats"] }

            /// Message.Conversation.User.AvatarImageFile.Format
            ///
            /// Parent Type: `AvailableFormat`
            public struct Format: LottaCoreAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.AvailableFormat }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("name", GraphQLEnum<LottaCoreAPI.ConversionFormat>.self),
                .field("url", String.self),
                .field("type", GraphQLEnum<LottaCoreAPI.FileType>.self),
              ] }

              public var name: GraphQLEnum<LottaCoreAPI.ConversionFormat> { __data["name"] }
              public var url: String { __data["url"] }
              public var type: GraphQLEnum<LottaCoreAPI.FileType> { __data["type"] }
            }
          }
        }
      }
    }
  }
}
