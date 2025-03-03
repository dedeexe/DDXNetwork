@testable import DDXNetwork
import Foundation

extension HTTPRequest {
    static func fixture(
        url: String = "https://test.tst",
        method: HTTPRequest.Method = .get,
        body: HTTPRequest.Body? = "{\"result\": \"success\"}".data(using: .utf8),
        parameters: HTTPRequest.Parameters = ["p1": "v1", "p2": "v2"],
        header: HTTPRequest.Header = ["h1": "v1", "h2": "v2"],
        timeout: TimeInterval = TimeInterval(42)
    ) -> HTTPRequest {
        HTTPRequest(url: url, method: method, parameters: parameters, header: header, body: body, timeout: timeout)
    }
}
