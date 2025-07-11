// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SearchUsersQuery: GraphQLQuery {
  public static let operationName: String = "SearchUsers"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query SearchUsers($searchtext: String!) { users: searchUsers(searchtext: $searchtext) { __typename id insertedAt updatedAt name class nickname avatarImageFile { __typename id formats(category: "AVATAR") { __typename name availability { __typename status } url type } } } }"#
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
      .field("searchUsers", alias: "users", [User].self, arguments: ["searchtext": .variable("searchtext")]),
    ] }

    public var users: [User] { __data["users"] }

    /// User
    ///
    /// Parent Type: `User`
    public struct User: LottaCoreAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", LottaCoreAPI.ID.self),
        .field("insertedAt", LottaCoreAPI.DateTime.self),
        .field("updatedAt", LottaCoreAPI.DateTime.self),
        .field("name", String?.self),
        .field("class", String?.self),
        .field("nickname", String?.self),
        .field("avatarImageFile", AvatarImageFile?.self),
      ] }

      public var id: LottaCoreAPI.ID { __data["id"] }
      public var insertedAt: LottaCoreAPI.DateTime { __data["insertedAt"] }
      public var updatedAt: LottaCoreAPI.DateTime { __data["updatedAt"] }
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
          .field("id", LottaCoreAPI.ID.self),
          .field("formats", [Format].self, arguments: ["category": "AVATAR"]),
        ] }

        public var id: LottaCoreAPI.ID { __data["id"] }
        public var formats: [Format] { __data["formats"] }

        /// User.AvatarImageFile.Format
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

          /// User.AvatarImageFile.Format.Availability
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
  }
}
