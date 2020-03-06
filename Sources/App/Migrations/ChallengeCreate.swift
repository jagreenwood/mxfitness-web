//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent

extension Challenge {
    struct Migration: Fluent.Migration {
        var name: String { "CreateChallenge" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Challenge.schema)
                .id()
                .field("start_date", .date, .required)
                .field("end_date", .date, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Challenge.schema).delete()
        }
    }
}
