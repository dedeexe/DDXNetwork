import XCTest
@testable import DDXNetwork

class HttpWorkerTests: XCTestCase {

    var sut: HttpWorker!
    var sessionMock: URLSessionMock!

    override func setUp() {
        sessionMock = URLSessionMock()
        sut = HttpWorker(urlSession: sessionMock)
    }

    func testMakingRequestFail() {
        let request = MockedRequest(url: "", method: .get, body: nil, headers: [:])
        let expecation = XCTestExpectation(description: "")

        sut.request(request, additionalHeaders: [:]) { result in
            switch result {
            case .failure(let err as NSError):
                XCTAssertEqual(err.code, 1000)
            default:
                XCTFail("Unexpected error case")
            }

            expecation.fulfill()
        }

        wait(for: [expecation], timeout: 10.0)
    }
    func testResponseErrorIsPresent() {
        let error = NSError(domain: "Error", code: 1234, userInfo: nil)
        sessionMock.error = error

        let request = MockedRequest(url: "https://www.test.com",
                                    method: .get,
                                    body: nil,
                                    headers: [:])

        let expecation = XCTestExpectation(description: "")

        sut.request(request, additionalHeaders: [:]) { result in
            switch result {
            case .failure(let err as NSError):
                XCTAssertEqual(err.code, 1234)
            default:
                XCTFail("Unexpected error case")
            }
            expecation.fulfill()
        }

        wait(for: [expecation], timeout: 10.0)
    }
    func testHTTPURLResponseErrorConversionFail() {
        sessionMock.response = UnknownResponse()
        let request = MockedRequest(url: "https://www.test.com",
                                    method: .get,
                                    body: nil,
                                    headers: [:])

        let expecation = XCTestExpectation(description: "")
        sut.request(request, additionalHeaders: [:]) { result in

            switch result {
            case .failure(let err as NSError):
                XCTAssertEqual(err.code, 601)
            default:
                XCTFail("Unexpected error case")
            }

            expecation.fulfill()
        }
        wait(for: [expecation], timeout: 10.0)
    }

    func testNotSuccessStatusCode() {
        let url = URL(string: "https://www.test.com")!
        let headers = ["Status": "success"]

        sessionMock.response = HTTPURLResponse(url: url,
                                               statusCode: 301,
                                               httpVersion: "1.1",
                                               headerFields: headers)

        let request = MockedRequest(url: "https://www.test.com",
                                    method: .get,
                                    body: nil,
                                    headers: [:])

        let expecation = XCTestExpectation(description: "")

        sut.request(request, additionalHeaders: [:]) { result in
            switch result {
            case .failure(let err as NSError):
                XCTAssertEqual(err.code, 301)
                XCTAssertEqual(err.userInfo["headers"] as? [String: String], headers)
            default:
                XCTFail("Unexpected error case")
            }
            expecation.fulfill()
        }

        wait(for: [expecation], timeout: 10.0)
    }

    func testSuccess() {
        let url = URL(string: "https://www.test.com")!
        let response = HTTPURLResponse(url: url,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: [:])

        let data = "success".data(using: .utf8)
        sessionMock.data = data
        sessionMock.response = response

        let request = MockedRequest(url: "https://www.test.com",
                                    method: .get,
                                    body: nil,
                                    headers: [:])

        let expecation = XCTestExpectation(description: "")

        sut.request(request, additionalHeaders: [:]) { result in
            switch result {
            case .success(let returnedData):
                XCTAssertEqual(returnedData, data)
            default:
                XCTFail("Unexpected error case")
            }
            expecation.fulfill()
        }

        wait(for: [expecation], timeout: 10.0)
    }
}

// =======
// HELPERS
// =======

struct MockedRequest: RequestModel {
    var url: String
    var method: HttpMethod
    var body: HttpBody?
    var headers: HttpHeaders
    var timeout: TimeInterval = 30
}

class DataTaskMock: URLSessionDataTask {
    private let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    override func resume() {
        action()
    }
}

class URLSessionMock: URLSession {
    var data: Data?
    var error: Error?
    var response: URLResponse?
    override func dataTask(with request: URLRequest,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        let response = self.response
        return DataTaskMock {
            completionHandler(data, response, error)
        }
    }
}

class UnknownResponse: URLResponse {
    init() {
        let url = URL(string: "http://www.test.com")!
        super.init(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
