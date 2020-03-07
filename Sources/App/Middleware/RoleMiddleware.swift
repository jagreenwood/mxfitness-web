//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Vapor

// Middleware to check the api user's role
struct RoleMiddleware: Middleware {
    let role: Role

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let user = try request.auth.get(User.self) else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }

        // Is user role greater then or equal to self.role
        if user.role >= role {
            return next.respond(to: request)
        }

        return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
    }
}
