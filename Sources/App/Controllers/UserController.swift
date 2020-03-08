//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent
import Vapor
import Leaf

struct UserController { }

/// API Calls
extension UserController {
    static func signup(_ request: Request) throws -> EventLoopFuture<User> {
        try createUser(request)
    }

    static func login(_ request: Request) throws -> EventLoopFuture<UserToken> {
        let user = try request.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: request.db)
            .map { token }
    }
}

/// Session Calls
extension UserController {
    static func signupView(_ request: Request) throws -> EventLoopFuture<View> {
        request.view.render("signup")
    }

    static func sessionSignup(_ request: Request) throws -> EventLoopFuture<Response> {
        try createUser(request).map { user in
            request.session.authenticate(user)

            return request.redirect(to: "/challenges")
        }
    }

    static func loginView(_ request: Request) throws -> EventLoopFuture<View> {
        request.view.render("login")
    }

    static func sessionLogin(_ request: Request) throws -> EventLoopFuture<Response> {
        /* Handle login via model decoding, authenticate user on request, redirect to user home view */
        let login = try request.content.decode(UserLogin.self)
        return User.authenticator().authenticate(basic: BasicAuthorization(username: login.username, password: login.password), for: request)
            .unwrap(or: Abort(.notFound, reason: "Bad credentials"))
            .map { user in
                request.session.authenticate(user)
                return request.redirect(to: "/challenges")
        }
    }

    static func userView(_ request: Request) throws -> EventLoopFuture<View> {
        let user = try request.auth.require(User.self)

        return user.$workouts.load(on: request.db)
            .flatMapThrowing { try user.response() }
            .flatMap { request.view.render("user", $0) }
    }
}

private extension UserController {
    static func createUser(_ request: Request) throws -> EventLoopFuture<User> {
        try UserCreate.validate(request)
        let create = try request.content.decode(UserCreate.self)
        let user = try User(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        return user.save(on: request.db)
            .map { user }
    }
}
