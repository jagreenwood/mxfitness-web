//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent

extension Workout {
    struct WorkoutCreate: Fluent.Migration {
        var name: String { "\(Self.self)" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Workout.schema)
                .id()
                .field("duration", .double, .required)
                .field("date", .date, .required)
                .field("type", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .field("challenge_id", .uuid, .required, .references("challenges", "id"))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Workout.schema).delete()
        }
    }
}
