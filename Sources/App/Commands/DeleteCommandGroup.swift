//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 6/9/20.
//

import Vapor

final class DeleteCommandGroup: CommandGroup {
    static var name = "delete"

    let help = "Delete platform objects"

    var commands: [String : AnyCommand] = [DeleteWorkoutCommand.name: DeleteWorkoutCommand()]

    var defaultCommand: AnyCommand? {
        self.commands[DeleteWorkoutCommand.name]
    }
}
