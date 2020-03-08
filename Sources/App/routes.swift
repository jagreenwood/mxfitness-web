import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {
    app.get { req in
        req.view.render("root")
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
    /// Render challenges view
    sessionProtected.get("challenges", use: ChallengeController.challengesView)
    /// Render challenge view
    sessionProtected.get("challenge", ":id", use: ChallengeController.challengeView)
    /// Session join challenge
    sessionProtected.post("challenge", ":id", "join", use: ChallengeController.sessionJoin)
    /// Render challenge workouts
    sessionProtected.get("challenge", ":id", "workouts", use: WorkoutController.challengeWorkoutsView)
    /// Session create workout
    sessionProtected.post("workouts", use: WorkoutController.sessionCreate)


    /// Admin protected middleware
    let adminSessionProtected = sessionProtected.grouped(RoleMiddleware(role: .admin))
    /// Session challenge create
    adminSessionProtected.post("challenges", use: ChallengeController.sessionCreate)
}
