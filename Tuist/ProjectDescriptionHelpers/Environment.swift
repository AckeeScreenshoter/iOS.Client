import ProjectDescription

public func environment() -> String {
    if case let .string(environment) = Environment.environment {
        return environment
    } else {
        return "Development"
    }
}
