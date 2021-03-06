//
//  ChallengeController.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Fluent
import Vapor
import Leaf
import Model

struct ChallengeController {
    static func challenge(for id: UUID, request: Request) -> EventLoopFuture<Challenge> {
        Challenge.query(on: request.db) // `find()` doesn't return query builder so can't eager load. Is there a better way?
            .with(\.$workouts)
            .with(\.$users)
            .filter(\._$id == id)
            .first()
            .unwrap(or: Abort(.notFound, reason: "Challenge not found."))
    }

    static func activeChallenge(request: Request) -> EventLoopFuture<Challenge?> {
        // Just sort on start date and get the first one for now. When more challenges are added, we'll need better filters and validation
        Challenge.query(on: request.db)
            .with(\.$workouts)
            .with(\.$users)
            .sort(\.$startDate)
            .first()
    }
}

/// API Calls
extension ChallengeController {
    static func userChallenge(request: Request) throws -> EventLoopFuture<ChallengeResponse> {
        throw Abort(.notImplemented)
    }

    static func leaderboard(_ request: Request) -> EventLoopFuture<Leaderboard> {
        activeChallenge(request: request)
            .unwrap(or: Abort(.notFound, reason: "Challenge Not Found."))
            .flatMapThrowing { try leaderboard(for: $0.requireID(), request: request) }
            .flatMap { $0 }
    }
}

/// Session Calls
extension ChallengeController {
    static func challengesView(_ request: Request) throws -> EventLoopFuture<View> {
        // authenticate user
        let user = try request.auth.require(User.self)

        // load workouts on user
        return user.$workouts.load(on: request.db).flatMap {
            Challenge.query(on: request.db).all()
                .flatMapThrowing { try $0.responses(request) }
                .map { $0 }.flatMap { $0 }
                .flatMap { request.view.render("challenges", $0) }
        }
    }

    static func challengeView(_ request: Request) throws -> EventLoopFuture<View> {
        challenge(for: request.parameters.get("id")!, request: request)
            .flatMap { request.view.render("challenge", $0) }
    }

    static func leaderboardViewRedirect(_ request: Request) throws -> EventLoopFuture<Response> {
        activeChallenge(request: request)
            .unwrap(or: Abort(.notFound, reason: "Challenge not found."))
            .flatMapThrowing { try request.redirect(to: "/challenge/\($0.requireID())/leaderboard") }
    }

    static func leaderboardView(_ request: Request) throws -> EventLoopFuture<View> {
        let userResponse = try request.auth.require(User.self).baseResponse()
        return leaderboard(for: request.parameters.get("id")!, request: request)
            .flatMap { request.view.render("leaderboard", AuthenticatedResponse(user: userResponse, response: $0)) }
    }

    static func sessionCreate(_ request: Request) throws -> EventLoopFuture<Response> {
        let create = try request.content.decode(ChallengeCreate.self)

        return try Challenge(name: create.name, startDate: create.startDate.date(), endDate: create.endDate.date()).save(on: request.db).map {
            request.redirect(to: "/challenges")
        }
    }

    static func sessionJoin(_ request: Request) throws -> EventLoopFuture<Response> {
        let user = try request.auth.require(User.self)

        return Challenge.find(request.parameters.get("id"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { challenge in
                user.challenge = challenge
                return user.save(on: request.db).flatMapThrowing {
                    try request.redirect(to: "/challenge/\(challenge.requireID())")
                }
        }
    }
}

private extension ChallengeController {
    static func leaderboard(for challengeID: UUID, request: Request) -> EventLoopFuture<Leaderboard> {
        ChallengeController.challenge(for: challengeID, request: request).map { challenge in
            challenge.workouts.map { $0.$user.load(on: request.db) }.flatten(on: request.eventLoop)
                .map { challenge }
        }
        .flatMap { $0 }
        .flatMapThrowing { challenge -> Leaderboard in
            let groupedWorkouts = Dictionary(grouping: challenge.workouts, by: \.user)
            let leaderboardUsers: [LeaderboardUser] = try groupedWorkouts.map {
                guard let avatar = $0.userAvatar else {
                    throw Abort(.internalServerError, reason: "Couldn't build avatar.")
                }

                return try LeaderboardUser(id: $0.requireID().uuidString, name: $0.name, avatar: avatar, totalWorkoutCount: $1.count, totalWorkoutDuration: $1.totalDuration)
            }

            let countSortedUsers = leaderboardUsers.sorted { $0.totalWorkoutCount > $1.totalWorkoutCount }
            let durationSortedUsers = leaderboardUsers.sorted { $0.totalWorkoutDuration > $1.totalWorkoutDuration }

            return Leaderboard(name: challenge.name, totalCount: countSortedUsers, totalDuration: durationSortedUsers)
        }
    }
}
