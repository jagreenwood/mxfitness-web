//
//  Date+Utils.swift
//  
//
//  Created by Jeremy Greenwood on 4/5/20.
//

import Vapor

private extension DateFormatter {
    static var dateInputFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()
}

extension Date {
    var iso8601: String {
        DateFormatter.dateInputFormat.string(from: self)
    }
}

extension String {
    func date() throws -> Date {
        guard let date = DateFormatter.dateInputFormat.date(from: self) else {
            throw Abort(.internalServerError, reason: "Could not convert string to Date.")
        }

        return date
    }
}
