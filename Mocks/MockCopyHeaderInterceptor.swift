@testable import DDXNetwork
import Foundation

class MockCopyHeaderInterceptor: HTTPServiceRequestInterceptor {
    var identifier: String { "interceptor" }

    var interceptCalls = 0
    var headers: [String: String]? = nil

    
    func intercept(request: URLRequest) -> URLRequest {
        interceptCalls += 1
        headers = request.allHTTPHeaderFields
        return request
    }
}
