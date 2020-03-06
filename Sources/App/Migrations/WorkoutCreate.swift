//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent

extension Workout {
    struct Migration: Fluent.Migration {
        var name: String { "CreateWorkout" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Workout.schema)
                .id()
                .field("duration", .double, .required)
                .field("type", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Workout.schema).delete()
        }
    }
}
