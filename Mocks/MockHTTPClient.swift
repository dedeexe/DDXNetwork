@testable import DDXNetwork

extension HTTPClient {
    static func mocked(
        urlSession: URLSessionMock,
        configuration: Configuration = .init()
    ) -> HTTPClient {
        return HTTPClient(urlSession: urlSession, configuration: configuration)
    }
}
