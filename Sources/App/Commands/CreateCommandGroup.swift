//
//  CreateCommandGroup.swift
//  
//
//  Created by Jeremy Greenwood on 3/13/20.
//

import Vapor

final class CreateCommandGroup: CommandGroup {
    static var name = "create"

    let help = "Create new platform objects"

    var commands: [String : AnyCommand] = [CreateUserCommand.name: CreateUserCommand(), CreateChallengeCommand.name: CreateChallengeCommand()]

    var defaultCommand: AnyCommand? {
        self.commands[CreateUserCommand.name]
    }
}
