import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {
    app.get { req in
        req.view.render("Root")
    }

    /// API  Create User
    app.post("user", "create", use: UserController.create)

    let passwordProtected = app.grouped(User.authenticator().middleware())

    /// API Login
    passwordProtected.post("user", "login", use: UserController.login)

    /// Token middleware for API routes
    let tokenProtected = app.grouped(UserToken.authenticator().middleware())

    /// Session user create
    app.post("create", use: UserController.sessionCreate)
    /// Session login
    app.post("login", use: UserController.sessionLogin)

    /// Session middleware for web requests
    let sessionProtected = app.grouped(app.fluent.sessions.middleware(for: User.self))
}
