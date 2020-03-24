//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent
import Vapor
import Leaf
import Model

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

    static func login(_ request: Request) throws -> EventLoopFuture<TokenResponse> {
        let user = try request.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: request.db)
            .map { token.response() }
    }
}

/// Session Calls
extension UserController {
    static func signupView(_ request: Request) throws -> EventLoopFuture<View> {
        request.view.render("signup")
    }

    static func sessionSignup(_ request: Request) throws -> EventLoopFuture<Response> {
        try createUser(request).flatMap { user in
            // query for active challenge and set it on user
            return ChallengeController.activeChallenge(request: request)
                .flatMap { challenge in
                    if challenge == nil {
                        request.logger.notice("No active challenge to link to user")
                    }

                    // optional challenge, want to break signup and throw an error
                    user.$challenge.id = challenge?.id

                    request.session.authenticate(user)
                    return user.save(on: request.db) }
                .flatMapThrowing { try request.redirect(to: "/user/\(user.requireID())") }
        }
    }

    static func loginView(_ request: Request) throws -> EventLoopFuture<View> {
        request.view.render("login")
    }

    static func sessionLogin(_ request: Request) throws -> EventLoopFuture<Response> {
        let login = try request.content.decode(UserLogin.self)
        return User.authenticator().authenticate(basic: BasicAuthorization(username: login.email, password: login.password), for: request)
            .unwrap(or: Abort(.notFound, reason: "Bad credentials"))
            .flatMapThrowing { user in
                request.auth.login(user)
                return try request.redirect(to: "/user/\(user.requireID())")
        }
    }

    static func userForIDView(_ request: Request) throws -> EventLoopFuture<View> {
        let authUser = try request.auth.require(User.self)
        let promise = request.eventLoop.makePromise(of: AuthenticatedResponse<UserResponse>.self)

        DispatchQueue.global().async {
            do {
                let userResponse = try user(for: request.parameters.get("id")!, request: request).wait().response(request).wait()
                let authUserResponse = try authUser.response(request).wait()

                promise.succeed(AuthenticatedResponse(user: authUserResponse, response: userResponse))
            } catch {
                promise.fail(error)
            }
        }

        return promise.futureResult.flatMap { request.view.render("user", $0) }
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
