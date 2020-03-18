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
    static func user(for id: UUID, request: Request) -> EventLoopFuture<User> {
        User.query(on: request.db) // `find()` doesn't return query builder so can't eager load. Is there a better way?
            .with(\.$workouts)
            .filter(\._$id == id)
            .first()
            .unwrap(or: Abort(.notFound))
    }
}

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
        try createUser(request).flatMap { user in
            request.session.authenticate(user)

            // query for active challenge and set it on user
            return ChallengeController.activeChallenge(request: request).flatMap { challenge in
                if challenge == nil {
                    request.logger.notice("No active challenge to link to user")
                }

                // optional challenge, want to break signup and throw an error
                user.challenge = challenge

                return user.save(on: request.db)
            }.map { request.redirect(to: "/") }
        }
    }

    static func loginView(_ request: Request) throws -> EventLoopFuture<View> {
        request.view.render("login")
    }

    static func sessionLogin(_ request: Request) throws -> EventLoopFuture<Response> {
        /* Get user, authenticate user on request, redirect to user home view */
        do {
            let user = try request.auth.require(User.self)
            request.session.authenticate(user)
            return request.eventLoop.makeSucceededFuture(request.redirect(to: "/"))
        } catch {
            return request.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Bad credentials"))
        }
    }

    static func userForIDView(_ request: Request) throws -> EventLoopFuture<View> {
        let authUser = try request.auth.require(User.self)

        return user(for: request.parameters.get("id")!, request: request).flatMapThrowing { try (authUser.response(), $0.response()) }
            .flatMap { request.view.render("user", AuthenticatedResponse(user: $0, response: $1)) }
    }

    static func sessionLogout(_ request: Request) throws -> EventLoopFuture<Response> {
        request.session.unauthenticate(User.self)
        return request.eventLoop.makeSucceededFuture(request.redirect(to: "/"))
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
