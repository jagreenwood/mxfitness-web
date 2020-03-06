import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {
    app.get { req in
        req.view.render("Root")
    }

    /// API  Create User
    app.post("user", "create", use: UserController.signup)

    let passwordProtected = app.grouped(User.authenticator().middleware())

    /// API Login
    passwordProtected.post("user", "login", use: UserController.login)

    /// Token middleware for API routes
    let tokenProtected = app.grouped(UserToken.authenticator().middleware())

    /// Render signup
    app.get("signup", use: UserController.signupView)
    /// Render login
    app.get("login", use: UserController.loginView)
    /// Session user create
    app.post("signup", use: UserController.sessionSignup)
    /// Session login
    app.post("login", use: UserController.sessionLogin)

    /// Session middleware for web requests
    let sessionProtected = app.grouped(app.fluent.sessions.middleware(for: User.self))
}
