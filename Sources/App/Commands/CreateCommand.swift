//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/13/20.
//

import Vapor

final class CreateCommandGroup: CommandGroup {
    static var name = "create"

    let help = "Create new platform objects"

    var commands: [String : AnyCommand] = [CreateUserCommand.name: CreateUserCommand()]

    var defaultCommand: AnyCommand? {
        self.commands[CreateUserCommand.name]
    }
}

final class CreateUserCommand: Command {
    struct Signature: CommandSignature {
        @Argument(name: "name", help: "The name of the user")
        var name: String

        @Argument(name: "email", help: "The user's email")
        var email: String

        @Argument(name: "password", help: "The password for the user")
        var password: String

        @Option(name: "role", short: "r", help: "The user's role: admin, member")
        var role: String?
    }

    static var name = "user"

    let help = "This command will say hello to a given name."

    func run(using context: CommandContext, signature: Signature) throws {
        let app = context.application

        var role: Role {
            guard let inputRole = signature.role, let role = Role(rawValue: inputRole) else {
                return .member
            }

            return role
        }

        app.logger.notice("Creating user...")
        let user = try User(name: signature.name, email: signature.email, role: role,
                            passwordHash: Bcrypt.hash(signature.password))
        try user.save(on: app.db).wait()

        app.logger.notice("User for \(signature.name) has been created")

    }
}
