import Observation

/// Drives a `NavigationStack` path. Injected into the SwiftUI environment.
@MainActor
@Observable
public final class Router {
    public var path: [CatRoute] = []

    public init() {}

    public func push(_ route: CatRoute) {
        path.append(route)
    }

    public func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    public func popToRoot() {
        path.removeAll()
    }
}
