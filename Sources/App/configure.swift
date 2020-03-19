import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "mxfitness"
    ), as: .psql)

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))
    app.views.use(.leaf)

    if !app.environment.isRelease {
        app.leaf.cache.isEnabled = false
    }

    app.migrations.add(Challenge.Migration())
    app.migrations.add(User.Migration())
    app.migrations.add(UserToken.Migration())
    app.migrations.add(Workout.Migration())

    // set up commands
    app.commands.use(CreateCommandGroup(), as: CreateCommandGroup.name)

    // create a new JSON encoder that uses unix-timestamp dates
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970

    // override the global encoder used for the `.json` media type
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    // register routes
    try routes(app)
}
