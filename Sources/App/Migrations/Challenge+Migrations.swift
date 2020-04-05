//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent

extension Challenge {
    struct ChallengeCreate: Fluent.Migration {
        var name: String { "\(Self.self)" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Challenge.schema)
                .id()
                .field("name", .string, .required)
                .field("start_date", .date, .required)
                .field("end_date", .date, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Challenge.schema).delete()
        }
    }
}
