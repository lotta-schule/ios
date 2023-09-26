// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct SelectUserInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    id: GraphQLNullable<ID> = nil
  ) {
    __data = InputDict([
      "id": id
    ])
  }

  public var id: GraphQLNullable<ID> {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }
}
