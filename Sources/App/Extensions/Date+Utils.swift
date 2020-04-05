//
//  Date+Utils.swift
//  
//
//  Created by Jeremy Greenwood on 4/5/20.
//

import Vapor

extension Date {
    var iso8601: String {
        ISO8601DateFormatter().string(from: self)
    }
}

extension String {
    func date() throws -> Date {
        guard let date = ISO8601DateFormatter().date(from: self) else {
            throw Abort(.internalServerError, reason: "Could not convert string to Date.")
        }

        return date
    }
}
