// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct UpdateDeviceInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    customName: GraphQLNullable<String> = nil,
    deviceType: GraphQLNullable<String> = nil,
    pushToken: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "customName": customName,
      "deviceType": deviceType,
      "pushToken": pushToken
    ])
  }

  public var customName: GraphQLNullable<String> {
    get { __data["customName"] }
    set { __data["customName"] = newValue }
  }

  public var deviceType: GraphQLNullable<String> {
    get { __data["deviceType"] }
    set { __data["deviceType"] = newValue }
  }

  public var pushToken: GraphQLNullable<String> {
    get { __data["pushToken"] }
    set { __data["pushToken"] = newValue }
  }
}
