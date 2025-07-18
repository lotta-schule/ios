// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AddMessageToConversationLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: GraphQLOperation.Variables? { ["id": id] }

  public struct Data: LottaCoreAPI.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.RootQueryType }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("conversation", Conversation?.self, arguments: [
        "id": .variable("id"),
        "markAsRead": true
      ]),
    ] }

    public var conversation: Conversation? {
      get { __data["conversation"] }
      set { __data["conversation"] = newValue }
    }

    public init(
      conversation: Conversation? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": LottaCoreAPI.Objects.RootQueryType.typename,
          "conversation": conversation._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.self)
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
            ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.Conversation.self)
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
          .field("id", LottaCoreAPI.ID.self),
          .field("name", String.self),
        ] }

        public var id: LottaCoreAPI.ID {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }
        public var name: String {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }

        public init(
          id: LottaCoreAPI.ID,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": LottaCoreAPI.Objects.UserGroup.typename,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.Conversation.Group.self)
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
          .field("id", LottaCoreAPI.ID.self),
          .field("name", String?.self),
          .field("nickname", String?.self),
          .field("avatarImageFile", AvatarImageFile?.self),
        ] }

        public var id: LottaCoreAPI.ID {
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
          id: LottaCoreAPI.ID,
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
              ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.Conversation.User.self)
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
            .field("id", LottaCoreAPI.ID.self),
          ] }

          public var id: LottaCoreAPI.ID {
            get { __data["id"] }
            set { __data["id"] = newValue }
          }

          public init(
            id: LottaCoreAPI.ID
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": LottaCoreAPI.Objects.File.typename,
                "id": id,
              ],
              fulfilledFragments: [
                ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.Conversation.User.AvatarImageFile.self)
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
          .field("id", LottaCoreAPI.ID.self),
          .field("content", String?.self),
          .field("insertedAt", LottaCoreAPI.DateTime.self),
          .field("updatedAt", LottaCoreAPI.DateTime.self),
          .field("files", [File]?.self),
          .field("user", User?.self),
        ] }

        public var id: LottaCoreAPI.ID {
          get { __data["id"] }
          set { __data["id"] = newValue }
        }
        public var content: String? {
          get { __data["content"] }
          set { __data["content"] = newValue }
        }
        public var insertedAt: LottaCoreAPI.DateTime {
          get { __data["insertedAt"] }
          set { __data["insertedAt"] = newValue }
        }
        public var updatedAt: LottaCoreAPI.DateTime {
          get { __data["updatedAt"] }
          set { __data["updatedAt"] = newValue }
        }
        public var files: [File]? {
          get { __data["files"] }
          set { __data["files"] = newValue }
        }
        public var user: User? {
          get { __data["user"] }
          set { __data["user"] = newValue }
        }

        public init(
          id: LottaCoreAPI.ID,
          content: String? = nil,
          insertedAt: LottaCoreAPI.DateTime,
          updatedAt: LottaCoreAPI.DateTime,
          files: [File]? = nil,
          user: User? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": LottaCoreAPI.Objects.Message.typename,
              "id": id,
              "content": content,
              "insertedAt": insertedAt,
              "updatedAt": updatedAt,
              "files": files._fieldData,
              "user": user._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.Conversation.Message.self)
            ]
          ))
        }

        /// Conversation.Message.File
        ///
        /// Parent Type: `File`
        public struct File: LottaCoreAPI.MutableSelectionSet {
          public var __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID.self),
            .field("filename", String.self),
            .field("fileType", GraphQLEnum<LottaCoreAPI.FileType>.self),
            .field("filesize", Int.self),
          ] }

          public var id: LottaCoreAPI.ID {
            get { __data["id"] }
            set { __data["id"] = newValue }
          }
          public var filename: String {
            get { __data["filename"] }
            set { __data["filename"] = newValue }
          }
          public var fileType: GraphQLEnum<LottaCoreAPI.FileType> {
            get { __data["fileType"] }
            set { __data["fileType"] = newValue }
          }
          public var filesize: Int {
            get { __data["filesize"] }
            set { __data["filesize"] = newValue }
          }

          public init(
            id: LottaCoreAPI.ID,
            filename: String,
            fileType: GraphQLEnum<LottaCoreAPI.FileType>,
            filesize: Int
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": LottaCoreAPI.Objects.File.typename,
                "id": id,
                "filename": filename,
                "fileType": fileType,
                "filesize": filesize,
              ],
              fulfilledFragments: [
                ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.Conversation.Message.File.self)
              ]
            ))
          }
        }

        /// Conversation.Message.User
        ///
        /// Parent Type: `User`
        public struct User: LottaCoreAPI.MutableSelectionSet {
          public var __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", LottaCoreAPI.ID.self),
            .field("name", String?.self),
            .field("nickname", String?.self),
            .field("avatarImageFile", AvatarImageFile?.self),
          ] }

          public var id: LottaCoreAPI.ID {
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
            id: LottaCoreAPI.ID,
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
                ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.Conversation.Message.User.self)
              ]
            ))
          }

          /// Conversation.Message.User.AvatarImageFile
          ///
          /// Parent Type: `File`
          public struct AvatarImageFile: LottaCoreAPI.MutableSelectionSet {
            public var __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { LottaCoreAPI.Objects.File }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", LottaCoreAPI.ID.self),
            ] }

            public var id: LottaCoreAPI.ID {
              get { __data["id"] }
              set { __data["id"] = newValue }
            }

            public init(
              id: LottaCoreAPI.ID
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": LottaCoreAPI.Objects.File.typename,
                  "id": id,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(AddMessageToConversationLocalCacheMutation.Data.Conversation.Message.User.AvatarImageFile.self)
                ]
              ))
            }
          }
        }
      }
    }
  }
}
