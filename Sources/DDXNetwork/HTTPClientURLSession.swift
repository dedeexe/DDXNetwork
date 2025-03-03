import Foundation

public protocol HTTPClientURLSession {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClientURLSession {
    ///
    /// Nothing implemented here.
    /// This protocol extensions is just for make the method `URLSession.data(for: delegate:) async throws -> (Data, URLResponse)` testable
    /// The mentioned method is implemented in an extension, so Swift doesn't allow id to be overriden.
    /// Having URLSession conforming with a protocol that demands the same method it already has implemented makes it flexibel for testing, allowing rewrite this
    /// method in a Mocked Object.
    ///
    /// Check `HTTPClient.swift` and  `URLSessionMock` for more details
    ///
}
