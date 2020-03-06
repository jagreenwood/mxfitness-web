//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Vapor

extension UserCreate: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(6...))
    }
}
