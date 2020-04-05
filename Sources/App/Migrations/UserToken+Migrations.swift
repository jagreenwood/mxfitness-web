//
//  UserTokenCreate.swift
//  
//
//  Created by Jeremy Greenwood on 3/5/20.
//

import Fluent

extension UserToken {
    struct UserTokenCreate: Fluent.Migration {
        var name: String { "\(Self.self)" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user_tokens")
                .id()
                .field("value", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .unique(on: "value")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user_tokens").delete()
        }
    }
}
