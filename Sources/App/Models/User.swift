//
//  User.swift
//  
//
//  Created by Jeremy Greenwood on 3/5/20.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "role")
    var role: Role

    @Field(key: "password_hash")
    var passwordHash: String

    @Children(for: \.$user)
    var workouts: [Workout]

    @OptionalParent(key: "challenge_id")
    var challenge: Challenge?

    init() { }

    init(id: UUID? = nil, name: String, email: String, role: Role = .member, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.passwordHash = passwordHash
    }

    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

extension User: ModelUser {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension User: SessionAuthenticatable {
    typealias SessionID = IDValue
    var sessionID: IDValue? { id }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
