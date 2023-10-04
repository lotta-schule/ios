// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RegisterDeviceMutation: GraphQLMutation {
  public static let operationName: String = "RegisterDevice"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation RegisterDevice($device: RegisterDeviceInput!) { device: registerDevice(device: $device) { __typename id } }"#
    ))

  public var device: RegisterDeviceInput

  public init(device: RegisterDeviceInput) {
    self.device = device
  }

  public var __variables: Variables? { ["device": device] }

  public struct Data: LottaCoreAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootMutationType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("registerDevice", alias: "device", Device?.self, arguments: ["device": .variable("device")]),
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
