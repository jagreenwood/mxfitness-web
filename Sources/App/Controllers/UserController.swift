//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent
import Vapor
import Leaf

struct UserController {
    static func create(_ request: Request) throws -> EventLoopFuture<User> {
        try User.Create.validate(request)
        let create = try request.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        return user.save(on: request.db)
            .map { user }
    }

    static func login(_ request: Request) throws -> EventLoopFuture<UserToken> {
        let user = try request.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: request.db)
            .map { token }
    }

    static func sessionCreate(_ request: Request) throws -> EventLoopFuture<Response> {
        throw Abort(.notImplemented)
        /* Handle create via model decoding, authenticate user on request, redirect to user home view */
    }

    static func sessionLogin(_ request: Request) throws -> EventLoopFuture<Response> {
        throw Abort(.notImplemented)
        /* Handle login via model decoding, authenticate user on request, redirect to user home view */
    }
}
