import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {
    app.get { req in
        req.view.render("Root")
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
}
