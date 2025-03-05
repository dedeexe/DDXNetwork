@testable import DDXNetwork
import Testing

struct HTTPRequestTests {

    @Test func builder() async throws {
        let data = "{\"result\": \"success\"}".data(using: .utf8)

        let expectedRequest = HTTPRequest
            .builder
            .url("https://test.tst")
            .method(.get)
            .paramter(key: "p1", value: "v1")
            .paramter(key: "p2", value: "v2")
            .header(key: "h1", value: "v1")
            .header(key: "h2", value: "v2")
            .body(data)
            .timeout(42)
            .build()

        let sut = HTTPRequest.fixture()

        #expect(expectedRequest.url == sut.url)
        #expect(expectedRequest.method == sut.method)
        #expect(expectedRequest.parameters == sut.parameters)
        #expect(expectedRequest.header == sut.header)
        #expect(expectedRequest.body == sut.body)
        #expect(expectedRequest.timeout == sut.timeout)
    }
}


