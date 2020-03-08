//
//  ChallengeController.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Fluent
import Vapor
import Leaf

struct ChallengeController {
    static func challenge(for id: UUID, request: Request) -> EventLoopFuture<Challenge> {
        Challenge.query(on: request.db) // `find()` doesn't return query builder so can't eager load. Is there a better way?
            .with(\.$workouts).with(\.$users)
            .filter(\._$id == id)
            .first()
            .unwrap(or: Abort(.notFound))
    }
}

/// Session Calls
extension ChallengeController {
    static func challengesView(_ request: Request) throws -> EventLoopFuture<View> {
        // authenticate user
        let user = try request.auth.require(User.self)
        // fetch all challenges, transform to responses, build the authResponse, return view future
        return Challenge.query(on: request.db).with(\.$users).all().flatMapEachCompactThrowing { try $0.response() }.flatMapThrowing { responses in
            try AuthenticatedResponse(user: user.response(), response: [Arguments.challenges: responses])
        }.flatMap { request.view.render("challenges", $0) }
    }

    static func challengeView(_ request: Request) throws -> EventLoopFuture<View> {
        _ = try request.auth.require(User.self)

        return challenge(for: request.parameters.get("id")!, request: request)
            .flatMap { request.view.render("challenge", $0) }
    }

    static func sessionCreate(_ request: Request) throws -> EventLoopFuture<Response> {
        let create = try request.content.decode(ChallengeCreate.self)

        return Challenge(name: create.name, startDate: create.startDate, endDate: create.endDate).save(on: request.db).map {
            request.redirect(to: "challenges")
        }
    }

    static func sessionJoin(_ request: Request) throws -> EventLoopFuture<Response> {
        let user = try request.auth.require(User.self)

        return Challenge.find(request.parameters.get("id"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { challenge in
                user.challenge = challenge
                return user.save(on: request.db).flatMapThrowing {
                    try request.redirect(to: "challenge/\(challenge.requireID())")
                }
        }
    }
}
