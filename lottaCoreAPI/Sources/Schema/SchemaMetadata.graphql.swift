// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == LottaCoreAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == LottaCoreAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == LottaCoreAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == LottaCoreAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Authresult": return LottaCoreAPI.Objects.Authresult
    case "AvailableFormat": return LottaCoreAPI.Objects.AvailableFormat
    case "Conversation": return LottaCoreAPI.Objects.Conversation
    case "Device": return LottaCoreAPI.Objects.Device
    case "File": return LottaCoreAPI.Objects.File
    case "FormatAvailability": return LottaCoreAPI.Objects.FormatAvailability
    case "Message": return LottaCoreAPI.Objects.Message
    case "RootMutationType": return LottaCoreAPI.Objects.RootMutationType
    case "RootQueryType": return LottaCoreAPI.Objects.RootQueryType
    case "RootSubscriptionType": return LottaCoreAPI.Objects.RootSubscriptionType
    case "Tenant": return LottaCoreAPI.Objects.Tenant
    case "TenantConfiguration": return LottaCoreAPI.Objects.TenantConfiguration
    case "User": return LottaCoreAPI.Objects.User
    case "UserGroup": return LottaCoreAPI.Objects.UserGroup
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
