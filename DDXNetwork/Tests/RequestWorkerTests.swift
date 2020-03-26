import XCTest
@testable import DDXNetwork

class RequestWorkerTests: XCTestCase {

    var sut: RequestWorker!
    var mockedHttp: HttpService!

    func testSuccessRawData() {
        let model = TestModel(dailyPhrase: "A1B2C3D4", value: 12345)

        setupSut(response: .success, successData: model.serialized())

        sut.requestData(from: Request()) { result in
            switch result {
            case .success(let resultData):
                XCTAssertEqual(resultData, model.serialized().data(using: .utf8)!)
            default:
                XCTFail("This test was expecting a success result")
            }
        }
    }

    func testFailRawData() {
        setupSut(response: .error, successData: "")

        sut.requestData(from: Request()) { result in
            switch result {
            case .failure(let error as NSError):
                XCTAssertEqual(error.code, 404)
                XCTAssertEqual(error.domain, "Not Found")
                XCTAssertNotEqual(error.domain, "Not found")
            default:
                XCTFail("This test was expecting a fail result")
            }
        }
    }

    func testSuccessDecodedObject() {
        let model = TestModel(dailyPhrase: "A1B2C3D4", value: 12345)

        setupSut(response: .success, successData: model.serialized())

        sut.request(TestModel.self, from: Request()) { result in
            switch result {
            case .success(let resultModel):
                XCTAssertEqual(resultModel, model)
            default:
                XCTFail("This test was expecting a success result")
            }
        }
    }

    // -------------------------
    func setupSut(response: HttpMock.ResponseType, successData: String) {
        mockedHttp = HttpMock(responseType: response,
                              successData: successData)

        sut = RequestWorker(http: mockedHttp)
    }
}

// --------------------------------------------------

// =======
// HELPERS
// =======

class HttpMock: HttpService {

    enum ResponseType {
        case success
        case error
    }

    var response: ResponseType
    var successData: String

    init(responseType: ResponseType, successData: String) {
        self.response = responseType
        self.successData = successData
    }

    func request(_ req: RequestModel, additionalHeaders: HttpHeaders, completion: HttpCompletion?) {
        if response == .error {
            let error = NSError(domain: "Not Found", code: 404, userInfo: [:])
            completion?(.failure(error))
            return
        }

        let result = successData.data(using: .utf8)!
        completion?(.success(result))
    }

}

struct Request: RequestModel {
    var url: String = ""
    var method: HttpMethod = .get
    var body: HttpBody?
    var headers: HttpHeaders = [:]
    var timeout: TimeInterval = 30
}

struct TestModel: Decodable, Equatable {
    let dailyPhrase: String
    let value: Int

    func serialized() -> String {
        return "{\"daily_phrase\":\"\(dailyPhrase)\", \"value\": \(value)}"
    }
}
