// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetConversationsQuery: GraphQLQuery {
  public static let operationName: String = "GetConversationsQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetConversationsQuery { conversations { __typename id updatedAt unreadMessages groups { __typename id name } users { __typename id name nickname avatarImageFile { __typename id formats(category: "AVATAR") { __typename name availability { __typename status } url type } } } messages { __typename id } } }"#
    ))

  public init() {}

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootQueryType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("conversations", [Conversation?]?.self),
    ] }

    public var conversations: [Conversation?]? { __data["conversations"] }

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
          .field("id", LottaCoreAPI.ID.self),
          .field("name", String.self),
        ] }

        public var id: LottaCoreAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
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
          .field("id", LottaCoreAPI.ID.self),
          .field("name", String?.self),
          .field("nickname", String?.self),
          .field("avatarImageFile", AvatarImageFile?.self),
        ] }

        public var id: LottaCoreAPI.ID { __data["id"] }
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
            .field("id", LottaCoreAPI.ID.self),
            .field("formats", [Format].self, arguments: ["category": "AVATAR"]),
          ] }

          public var id: LottaCoreAPI.ID { __data["id"] }
          public var formats: [Format] { __data["formats"] }

          /// Conversation.User.AvatarImageFile.Format
          ///
          /// Parent Type: `AvailableFormat`
          public struct Format: LottaCoreAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.AvailableFormat }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("name", GraphQLEnum<LottaCoreAPI.ConversionFormat>.self),
              .field("availability", Availability.self),
              .field("url", String.self),
              .field("type", GraphQLEnum<LottaCoreAPI.FileType>.self),
            ] }

            public var name: GraphQLEnum<LottaCoreAPI.ConversionFormat> { __data["name"] }
            public var availability: Availability { __data["availability"] }
            public var url: String { __data["url"] }
            public var type: GraphQLEnum<LottaCoreAPI.FileType> { __data["type"] }

            /// Conversation.User.AvatarImageFile.Format.Availability
            ///
            /// Parent Type: `FormatAvailability`
            public struct Availability: LottaCoreAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.FormatAvailability }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("status", GraphQLEnum<LottaCoreAPI.FormatAvailabilityStatus>.self),
              ] }

              public var status: GraphQLEnum<LottaCoreAPI.FormatAvailabilityStatus> { __data["status"] }
            }
          }
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
          .field("id", LottaCoreAPI.ID.self),
        ] }

        public var id: LottaCoreAPI.ID { __data["id"] }
      }
    }
  }
}
