@testable import DDXNetwork
import Foundation

class MockAddHeaderInterceptor: HTTPServiceRequestInterceptor {
    var identifier: String { "interceptor_add_header" }
    var interceptCalls = 0

    let key: String
    let value: String

    init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    func intercept(request: URLRequest) -> URLRequest {
        interceptCalls += 1
        var newRequest = request
        newRequest.addValue(value, forHTTPHeaderField: key)
        return newRequest
    }
}
