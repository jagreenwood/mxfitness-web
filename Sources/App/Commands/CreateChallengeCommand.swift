//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/18/20.
//

import Vapor

final class CreateChallengeCommand: Command {
    struct Signature: CommandSignature {
        @Argument(name: "name", help: "The name of the challenge")
        var name: String

        @Argument(name: "start_date", help: "The beginning of the challenge, expected format: 11/01/20")
        var startDate: String

        @Argument(name: "end_date", help: "The end of the challenge, expected format: 11/01/20")
        var endDate: String
    }

    static var name = "challenge"

    let help = "This command allows for the creation of a challenge."

    func run(using context: CommandContext, signature: Signature) throws {
        let app = context.application

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        guard let start = dateFormatter.date(from: signature.startDate) else {
            app.logger.error("Invalid start date format. Expected for is 11/01/20")
            return
        }

        guard let end = dateFormatter.date(from: signature.endDate) else {
            app.logger.error("Invalid end date format. Expected for is 11/01/20")
            return
        }

        app.logger.notice("Creating challenge...")
        try Challenge(name: signature.name, startDate: start, endDate: end).save(on: app.db).wait()
        app.logger.notice("Challenge named \(signature.name) has been created")
    }
}
