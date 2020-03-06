//
//  UserCreate.swift
//  
//
//  Created by Jeremy Greenwood on 3/5/20.
//

import Fluent
import Vapor

extension User {
    struct Migration: Fluent.Migration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users")
                .id()
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("password_hash", .string, .required)
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users").delete()
        }
    }
}
