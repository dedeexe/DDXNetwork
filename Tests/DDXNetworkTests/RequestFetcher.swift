@testable import DDXNetwork
import Foundation
import Testing

struct RequestFetcherTests {

    @Test("Fetcher must throw error") func fetch_dataFetcher_error() async throws {
        let session = URLSessionMock(result: .error(DataFetcherError.downloadFail("fail")))
        let httpClient = HTTPClient.mocked(urlSession: session)
        let dataFetcher = DataFetcher(client: httpClient)
        let sut = RequestFetcher(fetcher: dataFetcher, interceptors: [])

        do {
            _ = try await sut.fetch(MockObject.self, request: HTTPRequest.builder.url("https//nothi.ng").build())
            Issue.record("Reaching this point means the method has succeed. It must fail for this test case")
        } catch RequestFetcherError.downloadFail(let string)  {
            #expect(string == "The operation couldn’t be completed. (DDXNetwork.DataFetcherError error 0.)")
        } catch {
            Issue.record("Unexpected error")
        }
    }

    @Test("Fetcher must throw error") func fetch_decoding_error() async throws {
        let data = "{}".data(using: .utf8)!
        let session = URLSessionMock(result: .response(data, HTTPURLResponse.fixture()!))
        let httpClient = HTTPClient.mocked(urlSession: session)
        let dataFetcher = DataFetcher(client: httpClient)
        let sut = RequestFetcher(fetcher: dataFetcher, interceptors: [])

        do {
            _ = try await sut.fetch(MockObject.self, request: HTTPRequest.builder.url("https//nothi.ng").build())
            Issue.record("Reaching this point means the method has succeed")
        } catch RequestFetcherError.decodingError(let objectType) {
            #expect(objectType == "MockObject")
        } catch {
            Issue.record("Unexpected error")
        }
    }

    @Test("Fetcher must succeed") func fetch_success() async throws {
        let data = MockObject.data
        let session = URLSessionMock(result: .response(data, HTTPURLResponse.fixture()!))
        let httpClient = HTTPClient.mocked(urlSession: session)
        let dataFetcher = DataFetcher(client: httpClient)
        let sut = RequestFetcher(fetcher: dataFetcher, interceptors: [])

        do {
            let result = try await sut.fetch(MockObject.self, request: HTTPRequest.builder.url("https//nothi.ng").build())
            #expect(result == MockObject(string: "String", value: 42))
        } catch {
            Issue.record("Unexpected error")
        }
    }

}
