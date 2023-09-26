// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == LottaCoreAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == LottaCoreAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == LottaCoreAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == LottaCoreAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "RootQueryType": return LottaCoreAPI.Objects.RootQueryType
    case "Tenant": return LottaCoreAPI.Objects.Tenant
    case "TenantConfiguration": return LottaCoreAPI.Objects.TenantConfiguration
    case "File": return LottaCoreAPI.Objects.File
    case "RootSubscriptionType": return LottaCoreAPI.Objects.RootSubscriptionType
    case "Message": return LottaCoreAPI.Objects.Message
    case "User": return LottaCoreAPI.Objects.User
    case "Conversation": return LottaCoreAPI.Objects.Conversation
    case "UserGroup": return LottaCoreAPI.Objects.UserGroup
    case "RootMutationType": return LottaCoreAPI.Objects.RootMutationType
    case "Authresult": return LottaCoreAPI.Objects.Authresult
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
