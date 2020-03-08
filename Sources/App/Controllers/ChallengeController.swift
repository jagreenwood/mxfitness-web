//
//  ChallengeController.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Fluent
import Vapor
import Leaf

struct ChallengeController { }

/// Session Calls
extension ChallengeController {
    static func challengeView(_ request: Request) throws -> EventLoopFuture<View> {
        // authenticate user
        let user = try request.auth.require(User.self)
        // fetch all challenges, transform to responses, build the authResponse, return view future
        return Challenge.query(on: request.db).with(\.$users).all().flatMapEachCompactThrowing { try $0.response() }.flatMapThrowing { responses in
            try AuthenticatedResponse(user: user.response(), response: [Arguments.challenges: responses])
        }.flatMap { request.view.render("challenges", $0) }
    }

    static func sessionCreate(_ request: Request) throws -> EventLoopFuture<Response> {
        throw Abort(.notImplemented)
    }
}
