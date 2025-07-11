// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetCurrentUserQuery: GraphQLQuery {
  public static let operationName: String = "GetCurrentUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetCurrentUser { currentUser { __typename id insertedAt updatedAt lastSeen name nickname email class hideFullName enrollmentTokens unreadMessages hasChangedDefaultPassword avatarImageFile { __typename id formats(category: "AVATAR") { __typename name availability { __typename status } url type } } groups { __typename id name isAdminGroup } } }"#
    ))

  public init() {}

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootQueryType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("currentUser", CurrentUser?.self),
    ] }

    public var currentUser: CurrentUser? { __data["currentUser"] }

    /// CurrentUser
    ///
    /// Parent Type: `User`
    public struct CurrentUser: LottaCoreAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", LottaCoreAPI.ID.self),
        .field("insertedAt", LottaCoreAPI.DateTime.self),
        .field("updatedAt", LottaCoreAPI.DateTime.self),
        .field("lastSeen", LottaCoreAPI.DateTime?.self),
        .field("name", String?.self),
        .field("nickname", String?.self),
        .field("email", String?.self),
        .field("class", String?.self),
        .field("hideFullName", Bool.self),
        .field("enrollmentTokens", [String].self),
        .field("unreadMessages", Int?.self),
        .field("hasChangedDefaultPassword", Bool?.self),
        .field("avatarImageFile", AvatarImageFile?.self),
        .field("groups", [Group].self),
      ] }

      public var id: LottaCoreAPI.ID { __data["id"] }
      public var insertedAt: LottaCoreAPI.DateTime { __data["insertedAt"] }
      public var updatedAt: LottaCoreAPI.DateTime { __data["updatedAt"] }
      public var lastSeen: LottaCoreAPI.DateTime? { __data["lastSeen"] }
      public var name: String? { __data["name"] }
      public var nickname: String? { __data["nickname"] }
      public var email: String? { __data["email"] }
      public var `class`: String? { __data["class"] }
      public var hideFullName: Bool { __data["hideFullName"] }
      public var enrollmentTokens: [String] { __data["enrollmentTokens"] }
      public var unreadMessages: Int? { __data["unreadMessages"] }
      public var hasChangedDefaultPassword: Bool? { __data["hasChangedDefaultPassword"] }
      public var avatarImageFile: AvatarImageFile? { __data["avatarImageFile"] }
      public var groups: [Group] { __data["groups"] }

      /// CurrentUser.AvatarImageFile
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

        /// CurrentUser.AvatarImageFile.Format
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

          /// CurrentUser.AvatarImageFile.Format.Availability
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

      /// CurrentUser.Group
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
          .field("isAdminGroup", Bool.self),
        ] }

        public var id: LottaCoreAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var isAdminGroup: Bool { __data["isAdminGroup"] }
      }
    }
  }
}
