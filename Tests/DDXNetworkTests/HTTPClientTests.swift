@testable import DDXNetwork
import Foundation
import Testing

struct HTTPClientTests {

    var sut: HTTPClient!


    @Test func data_successResponse() async throws {
        let sut = makeSUT(result: makeDefaultResponse())
        let result = try await sut.requestData(.fixture(), interceptors: [])
        let string = String(data: result, encoding: .utf8) ?? ""

        #expect(string.contains("success"))
        #expect(string.contains("result"))
        #expect(string.contains("}"))
        #expect(string.contains("{"))
        #expect(string.contains(":"))
    }

    @Test func data_whenRequestHasInvalidURL_throwsException() async throws {
        let sut = makeSUT(result: .response(Data(capacity: 1) , HTTPURLResponse.fixture()!))

        do {
            _ = try await sut.requestData(.fixture(url: "https://invalid .com"), interceptors: [])
            Issue.record("This points shouldn't be reached")
        } catch {
            if let raiseError = error as? HTTPClientError {
                #expect(raiseError == HTTPClientError.invalidRequestURL)
            } else {
                Issue.record("Unexpected exception type: \(error)")
            }
        }
    }

    @Test func data_whenResponseStatusCodeMeansError_throwsException() async throws {
        let response = HTTPURLResponse.fixture(statusCode: 400)!
        let sut = makeSUT(result: .response(Data(capacity: 1), response))

        do {
            _ = try await sut.requestData(.fixture(), interceptors: [])
            Issue.record("This points shouldn't be reached")
        } catch {
            if case HTTPClientError.httpError(let statusCode, _) = error {
                #expect(statusCode == 400)
            } else {
                Issue.record("Unexpected exception type: \(error)")
            }
        }
    }

    @Test func data_whenResponseStatusCodeFrom300to399_throwsException() async throws {
        let response = HTTPURLResponse.fixture(statusCode: 350)!
        let sut = makeSUT(result: .response(Data(capacity: 1), response))

        do {
            _ = try await sut.requestData(.fixture(), interceptors: [])
            Issue.record("This points shouldn't be reached")
        } catch {
            if let raiseError = error as? HTTPClientError {
                #expect(raiseError == HTTPClientError.unknownError)
            } else {
                Issue.record("Unexpected exception type: \(error)")
            }
        }
    }

    @Test func data_executeInterceptor() async throws {
        let interceptor = MockCopyHeaderInterceptor()
        let interceptorAddField = MockAddHeaderInterceptor(key: "exe", value: "dede")
        let sut = makeSUT(
            result: makeDefaultResponse(),
            interceptors: [interceptorAddField, interceptor]
        )

        _ = try await sut.requestData(.fixture(), interceptors: [interceptor])

        #expect(interceptor.interceptCalls == 2)
        #expect(interceptor.headers == ["h1": "v1", "h2": "v2", "exe": "dede"])
        #expect(interceptorAddField.interceptCalls == 1)
    }

    //MARK: - Helpers

    private func makeSUT(result: URLSessionMock.Result, interceptors: [HTTPServiceRequestInterceptor] = []) -> HTTPClient {
        return HTTPClient(
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
