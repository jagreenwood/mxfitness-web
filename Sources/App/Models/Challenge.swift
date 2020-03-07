//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent
import Vapor

final class Challenge: Model {
    static let schema = "challenges"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "start_date")
    var startDate: Date

    @Field(key: "end_date")
    var endDate: Date

    @Children(for: \.$challenge)
    var users: [User]

    @Children(for: \.$challenge)
    var workouts: [Workout]

    init() { }

    init(id: UUID? = nil, name: String, startDate: Date, endDate: Date) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}
