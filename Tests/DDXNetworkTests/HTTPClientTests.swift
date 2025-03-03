@testable import DDXNetwork
import XCTest

final class HTTPClientTests: XCTestCase {

    var sut: HTTPClient!

    override func setUpWithError() throws {
        makeSUT(result: makeDefaultResponse())
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_data_successResponse() async throws {
        let result = try await sut.requestData(.fixture(), interceptors: [])
        let string = String(data: result, encoding: .utf8) ?? ""

        XCTAssertTrue(string.contains("success"))
        XCTAssertTrue(string.contains("result"))
        XCTAssertTrue(string.contains("}"))
        XCTAssertTrue(string.contains("{"))
        XCTAssertTrue(string.contains(":"))
    }

    func test_data_whenRequestHasInvalidURL_throwsException() async throws {
        makeSUT(result: .response(Data(capacity: 1) , HTTPURLResponse.fixture()!))

        do {
            _ = try await sut.requestData(.fixture(url: "https://invalid .com"), interceptors: [])
            XCTFail("This points shouldn't be reached")
        } catch {
            if let raiseError = error as? HTTPClientError {
                XCTAssertEqual(raiseError, HTTPClientError.invalidRequestURL)
            } else {
                XCTFail("Unexpected exception type: \(error)")
            }
        }
    }

    func test_data_whenResponseStatusCodeMeansError_throwsException() async throws {
        let response = HTTPURLResponse.fixture(statusCode: 400)!
        makeSUT(result: .response(Data(capacity: 1), response))

        do {
            _ = try await sut.requestData(.fixture(), interceptors: [])
            XCTFail("This points shouldn't be reached")
        } catch {
            if case HTTPClientError.httpError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 400)
            } else {
                XCTFail("Unexpected exception type: \(error)")
            }
        }
    }

    func test_data_whenResponseStatusCodeFrom300to399_throwsException() async throws {
        let response = HTTPURLResponse.fixture(statusCode: 350)!
        makeSUT(result: .response(Data(capacity: 1), response))

        do {
            _ = try await sut.requestData(.fixture(), interceptors: [])
            XCTFail("This points shouldn't be reached")
        } catch {
            if let raiseError = error as? HTTPClientError {
                XCTAssertEqual(raiseError, HTTPClientError.unknownError)
            } else {
                XCTFail("Unexpected exception type: \(error)")
            }
        }
    }

    func test_data_executeInterceptor() async throws {
        let interceptor = MockCopyHeaderInterceptor()
        let interceptorAddField = MockAddHeaderInterceptor(key: "exe", value: "dede")
        makeSUT(
            result: makeDefaultResponse(),
            interceptors: [interceptorAddField, interceptor]
        )

        _ = try await sut.requestData(.fixture(), interceptors: [interceptor])

        XCTAssertEqual(interceptor.interceptCalls, 2)
        XCTAssertEqual(interceptor.headers, ["h1": "v1", "h2": "v2", "exe": "dede"])
        XCTAssertEqual(interceptorAddField.interceptCalls, 1)
    }


    private func makeSUT(result: URLSessionMock.Result, interceptors: [HTTPServiceRequestInterceptor] = []) {
        sut = HTTPClient(
            urlSession: URLSessionMock(result: result),
            configuration: HTTPClient.Configuration(interceptors: interceptors)
        )
    }

    private func makeDefaultResponse() -> URLSessionMock.Result {
        let data = "{\"result\": \"success\"}".data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://exe.de.de")!,
            statusCode: 200,
            httpVersion: "2.0",
            headerFields: ["result1": "value1"]
        )

        return .response(data, response!)
    }
}
