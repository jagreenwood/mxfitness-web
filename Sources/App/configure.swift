import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    if app.environment.isRelease {
        try app.databases.use(.postgres(
            url: URL(string: Environment.get("DATABASE_URL")!)!
        ), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            username: Environment.get("DATABASE_USERNAME") ?? "postgres",
            password: Environment.get("DATABASE_PASSWORD") ?? "",
            database: Environment.get("DATABASE_NAME") ?? "mxfitness"
        ), as: .psql)
    }

    if let port = Environment.get("PORT").flatMap(Int.init) {
        app.server.configuration.port = port
    }

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))
    app.views.use(.leaf)

    if !app.environment.isRelease {
        app.leaf.cache.isEnabled = false
    }

    app.migrations.add(Challenge.ChallengeCreate())
    app.migrations.add(User.UserCreate())
    app.migrations.add(UserToken.UserTokenCreate())
    app.migrations.add(Workout.WorkoutCreate())

    // set up commands
    app.commands.use(CreateCommandGroup(), as: CreateCommandGroup.name)
    app.commands.use(DeleteCommandGroup(), as: DeleteCommandGroup.name)

    // create a new JSON encoder/decoder that uses unix-timestamp dates
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    // override the global encoder used for the `.json` media type
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    // register routes
    try routes(app)
}
