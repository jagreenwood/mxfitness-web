//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent
import Vapor

final class Workout: Model {
    static let schema = "workouts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "duration")
    var duration: TimeInterval

    @Field(key: "date")
    var date: Date

    @Field(key: "type")
    var type: String

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "challenge_id")
    var challenge: Challenge

    init() { }

    init(id: UUID? = nil, duration: TimeInterval, date: Date, type: String, userID: User.IDValue, challengeID: Challenge.IDValue) {
        self.id = id
        self.duration = duration
        self.date = date
        self.type = type
        self.$user.id = userID
        self.$challenge.id = challengeID
    }
}
