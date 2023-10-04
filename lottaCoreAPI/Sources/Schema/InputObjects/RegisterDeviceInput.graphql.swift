// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct RegisterDeviceInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    customName: GraphQLNullable<String> = nil,
    deviceType: GraphQLNullable<String> = nil,
    modelName: GraphQLNullable<String> = nil,
    operatingSystem: GraphQLNullable<String> = nil,
    platformId: String,
    pushToken: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "customName": customName,
      "deviceType": deviceType,
      "modelName": modelName,
      "operatingSystem": operatingSystem,
      "platformId": platformId,
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

  public var modelName: GraphQLNullable<String> {
    get { __data["modelName"] }
    set { __data["modelName"] = newValue }
  }

  public var operatingSystem: GraphQLNullable<String> {
    get { __data["operatingSystem"] }
    set { __data["operatingSystem"] = newValue }
  }

  public var platformId: String {
    get { __data["platformId"] }
    set { __data["platformId"] = newValue }
  }

  public var pushToken: GraphQLNullable<String> {
    get { __data["pushToken"] }
    set { __data["pushToken"] = newValue }
  }
}
