@testable import DDXNetwork
import XCTest

final class HTTPRequestTests: XCTestCase {

    var sut: HTTPRequest!

    override func setUp() async throws {
        sut = .fixture()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_builder() throws {
        let data = "{\"result\": \"success\"}".data(using: .utf8)
        let expectedRequest = HTTPRequest(
            url: "https://test.tst",
            method: .get,
            parameters: ["p1": "v1", "p2": "v2"],
            header: ["h1": "v1", "h2": "v2"],
            body: data,
            timeout: 42
        )

        XCTAssertEqual(expectedRequest.url, sut.url)
        XCTAssertEqual(expectedRequest.method, sut.method)
        XCTAssertEqual(expectedRequest.parameters, sut.parameters)
        XCTAssertEqual(expectedRequest.header, sut.header)
        XCTAssertEqual(expectedRequest.body, sut.body)
        XCTAssertEqual(expectedRequest.timeout, sut.timeout)
    }
}


