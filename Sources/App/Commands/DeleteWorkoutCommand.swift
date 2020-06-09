//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 6/9/20.
//

import Vapor

final class DeleteWorkoutCommand: Command {
    struct Signature: CommandSignature {
        @Argument(name: "id", help: "The id of the workout")
        var id: String
    }

    static var name = "workout"

    let help = "This command allows for the deletion of a workout."

    func run(using context: CommandContext, signature: Signature) throws {
        let app = context.application

        guard let workout = try Workout.find(UUID(uuidString: signature.id), on: app.db).wait() else {
            app.logger.notice("Could not find workout with id \(signature.id)")
            return
        }

        try workout.delete(on: app.db).wait()
        app.logger.notice("Workout successfully deleted")
    }
}
