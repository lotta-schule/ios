// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class DeleteDeviceMutation: GraphQLMutation {
  public static let operationName: String = "DeleteDevice"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation DeleteDevice($id: ID!) { device: deleteDevice(id: $id) { __typename id } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootMutationType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("deleteDevice", alias: "device", Device?.self, arguments: ["id": .variable("id")]),
    ] }

    public var device: Device? { __data["device"] }

    /// Device
    ///
    /// Parent Type: `Device`
    public struct Device: LottaCoreAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.Device }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", LottaCoreAPI.ID?.self),
      ] }

      public var id: LottaCoreAPI.ID? { __data["id"] }
    }
  }
}
