import Foundation

extension HTTPURLResponse {
    static func fixture(
        url: URL = URL(string: "https://test.tst")!,
        statusCode: Int = 200,
        httpVersion: String = "2.0",
        headerFields: [String: String] = ["result1": "value1"]
    ) -> HTTPURLResponse? {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
        )
    }
}
