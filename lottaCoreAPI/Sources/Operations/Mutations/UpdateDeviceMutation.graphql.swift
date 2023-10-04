// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateDeviceMutation: GraphQLMutation {
  public static let operationName: String = "UpdateDevice"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateDevice($id: ID!, $device: UpdateDeviceInput!) { device: updateDevice(id: $id, device: $device) { __typename id } }"#
    ))

  public var id: ID
  public var device: UpdateDeviceInput

  public init(
    id: ID,
    device: UpdateDeviceInput
  ) {
    self.id = id
    self.device = device
  }

  public var __variables: Variables? { [
    "id": id,
    "device": device
  ] }

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootMutationType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateDevice", alias: "device", Device?.self, arguments: [
        "id": .variable("id"),
        "device": .variable("device")
      ]),
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
