import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "mxfitness"
    ), as: .psql)

    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))
    app.views.use(.leaf)

    if !app.environment.isRelease {
        app.leaf.cache.isEnabled = false
    }

    app.migrations.add(User.Migration())
    app.migrations.add(UserToken.Migration())

    // register routes
    try routes(app)
}
