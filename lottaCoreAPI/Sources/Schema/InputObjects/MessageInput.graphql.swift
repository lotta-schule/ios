// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct MessageInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    content: GraphQLNullable<String> = nil,
    files: GraphQLNullable<[SelectFileInput?]> = nil,
    recipientGroup: GraphQLNullable<SelectUserGroupInput> = nil,
    recipientUser: GraphQLNullable<SelectUserInput> = nil
  ) {
    __data = InputDict([
      "content": content,
      "files": files,
      "recipientGroup": recipientGroup,
      "recipientUser": recipientUser
    ])
  }

  public var content: GraphQLNullable<String> {
    get { __data["content"] }
    set { __data["content"] = newValue }
  }

  public var files: GraphQLNullable<[SelectFileInput?]> {
    get { __data["files"] }
    set { __data["files"] = newValue }
  }

  public var recipientGroup: GraphQLNullable<SelectUserGroupInput> {
    get { __data["recipientGroup"] }
    set { __data["recipientGroup"] = newValue }
  }

  public var recipientUser: GraphQLNullable<SelectUserInput> {
    get { __data["recipientUser"] }
    set { __data["recipientUser"] = newValue }
  }
}
