import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {
    try sessionRoutes(app)
    try apiRoutes(app)
}

func sessionRoutes(_ app: Application) throws {
    app.get { request -> EventLoopFuture<Response> in
        var redirect: Response {
            do {
                let user = try request.auth.require(User.self)
                return try request.redirect(to: "/user/\(user.requireID())")
            } catch {
                return request.redirect(to: "login")
            }
        }

        return request.eventLoop.makeSucceededFuture(redirect)
    }

    /// Session middleware for web requests
    let passwordProtected = app.grouped(User.authenticator().middleware())

    /// Render signup
    app.get("signup", use: UserController.signupView)
    /// Render login
    app.get("login", use: UserController.loginView)
    /// Session user create
    app.post("signup", use: UserController.sessionSignup)
    /// Session login
    passwordProtected.post("login", use: UserController.sessionLogin)

    /// Session middleware for web requests
    let sessionProtected = app.grouped(app.fluent.sessions.middleware(for: User.self))
    /// Render challenges view
    sessionProtected.get("challenges", use: ChallengeController.challengesView)
    /// Render challenge view
    sessionProtected.get("challenge", ":id", use: ChallengeController.challengeView)
    /// Render challenge workouts
    sessionProtected.get("challenge", ":id", "workouts", use: WorkoutController.challengeWorkoutsView)
    /// Render challenge leaderboard
    sessionProtected.get("challenge", ":id", "leaderboard", use: ChallengeController.leaderboardView)
    /// Session join challenge
    sessionProtected.post("challenge", ":id", "join", use: ChallengeController.sessionJoin)
    /// Render user for id view
    sessionProtected.get("user", ":id", use: UserController.userForIDView)
    /// Render leaderboard view, redirect shortcut to /challenge/:id/leaderboard
    sessionProtected.get("leaderboard", use: ChallengeController.leaderboardViewRedirect)
    /// Session create workout
    sessionProtected.post("workouts", use: WorkoutController.sessionCreate)
    /// Session logout
    sessionProtected.get("logout", use: UserController.sessionLogout)

    /// Admin protected middleware
    let adminSessionProtected = sessionProtected.grouped(RoleMiddleware(role: .admin))
    /// Session challenge create
    adminSessionProtected.post("challenges", use: ChallengeController.sessionCreate)
}

func apiRoutes(_ app: Application) throws {
    let apiV1 = app.grouped("api", "v1")
    /// API  Create User
    apiV1.post("signup", use: UserController.signup)

    let passwordProtected = apiV1.grouped(User.authenticator().middleware())
    /// API Login
    passwordProtected.post("login", use: UserController.login)

    let tokenProtected = apiV1.grouped(UserToken.authenticator().middleware())
    /// POST Workout
    tokenProtected.post("workout", use: WorkoutController.create)
}
