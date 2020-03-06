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

    @Enum(key: "type")
    var type: WorkoutType

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "challenge_id")
    var challenge: Challenge

    init() { }

    init(id: UUID? = nil, duration: TimeInterval, type: WorkoutType, userID: User.IDValue, challengeID: Challenge.IDValue) {
        self.id = id
        self.duration = duration
        self.type = type
        self.$user.id = userID
        self.$challenge.id = challengeID
    }
}
