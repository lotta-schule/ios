// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetTenantQuery: GraphQLQuery {
  public static let operationName: String = "GetTenant"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetTenant { tenant { __typename id title slug host configuration { __typename backgroundImageFile { __typename id formats(category: "PAGEBG") { __typename name url type } } logoImageFile { __typename formats(category: "LOGO") { __typename name url type } } customTheme userMaxStorageConfig } } }"#
    ))

  public init() {}

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootQueryType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("tenant", Tenant?.self),
    ] }

    public var tenant: Tenant? { __data["tenant"] }

    /// Tenant
    ///
    /// Parent Type: `Tenant`
    public struct Tenant: LottaCoreAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.Tenant }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", LottaCoreAPI.ID.self),
        .field("title", String.self),
        .field("slug", String.self),
        .field("host", String.self),
        .field("configuration", Configuration.self),
      ] }

      public var id: LottaCoreAPI.ID { __data["id"] }
      public var title: String { __data["title"] }
      public var slug: String { __data["slug"] }
      public var host: String { __data["host"] }
      public var configuration: Configuration { __data["configuration"] }

      /// Tenant.Configuration
      ///
      /// Parent Type: `TenantConfiguration`
      public struct Configuration: LottaCoreAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.TenantConfiguration }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("backgroundImageFile", BackgroundImageFile?.self),
          .field("logoImageFile", LogoImageFile?.self),
          .field("customTheme", LottaCoreAPI.Json?.self),
          .field("userMaxStorageConfig", String?.self),
        ] }

        public var backgroundImageFile: BackgroundImageFile? { __data["backgroundImageFile"] }
        public var logoImageFile: LogoImageFile? { __data["logoImageFile"] }
        public var customTheme: LottaCoreAPI.Json? { __data["customTheme"] }
        public var userMaxStorageConfig: String? { __data["userMaxStorageConfig"] }

        /// Tenant.Configuration.BackgroundImageFile
        ///
        /// Parent Type: `File`
        public struct BackgroundImageFile: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID.self),
            .field("formats", [Format].self, arguments: ["category": "PAGEBG"]),
          ] }

          public var id: LottaCoreAPI.ID { __data["id"] }
          public var formats: [Format] { __data["formats"] }

          /// Tenant.Configuration.BackgroundImageFile.Format
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

        /// Tenant.Configuration.LogoImageFile
        ///
        /// Parent Type: `File`
        public struct LogoImageFile: LottaCoreAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("formats", [Format].self, arguments: ["category": "LOGO"]),
          ] }

          public var formats: [Format] { __data["formats"] }

          /// Tenant.Configuration.LogoImageFile.Format
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
