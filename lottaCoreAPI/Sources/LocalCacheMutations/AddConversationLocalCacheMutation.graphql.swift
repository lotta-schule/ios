// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AddConversationLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

  public init() {}

  public struct Data: LottaCoreAPI.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootQueryType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("conversations", [Conversation?]?.self),
    ] }

    public var conversations: [Conversation?]? {
      get { __data["conversations"] }
      set { __data["conversations"] = newValue }
    }

    public init(
      conversations: [Conversation?]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": LottaCoreAPI.Objects.RootQueryType.typename,
          "conversations": conversations._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(AddConversationLocalCacheMutation.Data.self)
        ]
      ))
    }

    /// Conversation
    ///
    /// Parent Type: `Conversation`
    public struct Conversation: LottaCoreAPI.MutableSelectionSet {
      public var __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.Conversation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", LottaCoreAPI.ID?.self),
        .field("updatedAt", LottaCoreAPI.DateTime?.self),
        .field("unreadMessages", Int?.self),
        .field("groups", [Group]?.self),
        .field("users", [User]?.self),
        .field("messages", [Message]?.self),
      ] }

      public var id: LottaCoreAPI.ID? {
        get { __data["id"] }
        set { __data["id"] = newValue }
      }
      public var updatedAt: LottaCoreAPI.DateTime? {
        get { __data["updatedAt"] }
        set { __data["updatedAt"] = newValue }
      }
      public var unreadMessages: Int? {
        get { __data["unreadMessages"] }
        set { __data["unreadMessages"] = newValue }
      }
      public var groups: [Group]? {
        get { __data["groups"] }
        set { __data["groups"] = newValue }
      }
      public var users: [User]? {
        get { __data["users"] }
        set { __data["users"] = newValue }
      }
      public var messages: [Message]? {
        get { __data["messages"] }
        set { __data["messages"] = newValue }
      }

      public init(
        id: LottaCoreAPI.ID? = nil,
        updatedAt: LottaCoreAPI.DateTime? = nil,
        unreadMessages: Int? = nil,
        groups: [Group]? = nil,
        users: [User]? = nil,
        messages: [Message]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": LottaCoreAPI.Objects.Conversation.typename,
            "id": id,
            "updatedAt": updatedAt,
            "unreadMessages": unreadMessages,
            "groups": groups._fieldData,
            "users": users._fieldData,
            "messages": messages._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(AddConversationLocalCacheMutation.Data.Conversation.self)
          ]
        ))
      }

      /// Conversation.Group
      ///
      /// Parent Type: `UserGroup`
      public struct Group: LottaCoreAPI.MutableSelectionSet {
        public var __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.UserGroup }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
          .field("name", String?.self),
        ] }

        public var id: LottaCoreAPI.ID? {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }
        public var name: String? {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }

        public init(
          id: LottaCoreAPI.ID? = nil,
          name: String? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": LottaCoreAPI.Objects.UserGroup.typename,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(AddConversationLocalCacheMutation.Data.Conversation.Group.self)
            ]
          ))
        }
      }

      /// Conversation.User
      ///
      /// Parent Type: `User`
      public struct User: LottaCoreAPI.MutableSelectionSet {
        public var __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
          .field("name", String?.self),
          .field("nickname", String?.self),
          .field("avatarImageFile", AvatarImageFile?.self),
        ] }

        public var id: LottaCoreAPI.ID? {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }
        public var name: String? {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }
        public var nickname: String? {
          get { __data["nickname"] }
          set { __data["nickname"] = newValue }
        }
        public var avatarImageFile: AvatarImageFile? {
          get { __data["avatarImageFile"] }
          set { __data["avatarImageFile"] = newValue }
        }

        public init(
          id: LottaCoreAPI.ID? = nil,
          name: String? = nil,
          nickname: String? = nil,
          avatarImageFile: AvatarImageFile? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": LottaCoreAPI.Objects.User.typename,
              "id": id,
              "name": name,
              "nickname": nickname,
              "avatarImageFile": avatarImageFile._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(AddConversationLocalCacheMutation.Data.Conversation.User.self)
            ]
          ))
        }

        /// Conversation.User.AvatarImageFile
        ///
        /// Parent Type: `File`
        public struct AvatarImageFile: LottaCoreAPI.MutableSelectionSet {
          public var __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID?.self),
          ] }

          public var id: LottaCoreAPI.ID? {
            get { __data["id"] }
            set { __data["id"] = newValue }
          }

          public init(
            id: LottaCoreAPI.ID? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": LottaCoreAPI.Objects.File.typename,
                "id": id,
              ],
              fulfilledFragments: [
                ObjectIdentifier(AddConversationLocalCacheMutation.Data.Conversation.User.AvatarImageFile.self)
              ]
            ))
          }
        }
      }

      /// Conversation.Message
      ///
      /// Parent Type: `Message`
      public struct Message: LottaCoreAPI.MutableSelectionSet {
        public var __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.Message }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", LottaCoreAPI.ID?.self),
        ] }

        public var id: LottaCoreAPI.ID? {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }

        public init(
          id: LottaCoreAPI.ID? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": LottaCoreAPI.Objects.Message.typename,
              "id": id,
            ],
            fulfilledFragments: [
              ObjectIdentifier(AddConversationLocalCacheMutation.Data.Conversation.Message.self)
            ]
          ))
        }
      }
    }
  }
}
