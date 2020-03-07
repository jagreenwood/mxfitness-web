//
//  Role.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Foundation

enum Role: String, Codable {
    case member
    case admin
}

extension Role: Comparable {
    public static func < (lhs: Role, rhs: Role) -> Bool {
        switch lhs {
        case .admin:
            return false
        case .member:
            return .admin == rhs
        }
    }

    public static func > (lhs: Role, rhs: Role) -> Bool {
        switch lhs {
        case .admin:
            return .member == rhs
        case .member:
            return false
        }
    }
}
