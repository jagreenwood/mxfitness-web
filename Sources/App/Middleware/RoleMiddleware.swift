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

    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard let user = try request.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }

        // Is user role greater then or equal to self.role
        if user.role >= role {
            return try next.respond(to: request)
        }

        throw Abort(.unauthorized)
    }
}
