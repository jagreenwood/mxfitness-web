//
//  UserCreate.swift
//  
//
//  Created by Jeremy Greenwood on 3/5/20.
//

import Fluent
import Vapor

extension User {
    struct UserCreate: Fluent.Migration {
        var name: String { "\(Self.self)" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users")
                .id()
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("role", .string, .required)
                .field("password_hash", .string, .required)
                .field("challenge_id", .uuid, .references("challenges", "id"))
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users").delete()
        }
    }
}
