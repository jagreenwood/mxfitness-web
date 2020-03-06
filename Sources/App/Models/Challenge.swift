//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent
import Vapor

final class Challenge: Model {
    static let schema = "challenges"

    @ID(key: .id)
    var id: UUID?

    @Children(for: \.$challenge)
    var users: [User]

    init() { }
}
