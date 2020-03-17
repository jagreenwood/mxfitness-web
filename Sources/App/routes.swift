import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {
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

    /// API  Create User
    app.post("user", "create", use: UserController.signup)

    let tokenProtected = app.grouped(UserToken.authenticator().middleware())

    /// API Login
    tokenProtected.post("user", "login", use: UserController.login)

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
    /// Render user view
    sessionProtected.get("user", use: UserController.userView)
    /// Session join challenge
    sessionProtected.post("challenge", ":id", "join", use: ChallengeController.sessionJoin)
    /// Session create workout
    sessionProtected.post("workouts", use: WorkoutController.sessionCreate)
    /// Session logout
    sessionProtected.get("logout", use: UserController.sessionLogout)

    /// Admin protected middleware
    let adminSessionProtected = sessionProtected.grouped(RoleMiddleware(role: .admin))
    /// Session challenge create
    adminSessionProtected.post("challenges", use: ChallengeController.sessionCreate)
}
