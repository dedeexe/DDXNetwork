@testable import DDXNetwork
import Foundation

class URLSessionMock: HTTPClientURLSession {
    enum Result {
        case error(Error)
        case response(Data, URLResponse)
    }

    let result: Result

    init(result: Result) {
        self.result = result
    }

    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        switch result {
        case .error(let error):
            throw error
        case .response(let data, let urlResponse):
            return(data, urlResponse)
        }
    }
}
