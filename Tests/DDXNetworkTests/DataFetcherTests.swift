@testable import DDXNetwork
import Foundation
import Testing

struct DataFetcherTests {

    @Test("Fetcher must throw error") func fetch_error() async throws {
        let session = URLSessionMock(result: .error(DataFetcherError.downloadFail("fail")))
        let httpClient = HTTPClient.mocked(urlSession: session)
        let sut = DataFetcher(client: httpClient)

        do {
            _ = try await sut.fetch(request: HTTPRequest.builder.url("https//nothi.ng").build())
            Issue.record("Reaching this point means the method has succeed")
        } catch DataFetcherError.downloadFail(let string) {
            #expect(string == "The operation couldn’t be completed. (DDXNetwork.DataFetcherError error 0.)")
        } catch {
            Issue.record("Unexpected error")
        }
    }

    @Test("Fetcher must succeed") func fetch_success() async throws {
        let data = "Some data".data(using: .utf8)!
        let session = URLSessionMock(result: .response(data, HTTPURLResponse.fixture()!))
        let httpClient = HTTPClient.mocked(urlSession: session)
        let sut = DataFetcher(client: httpClient)

        do {
            let result = try await sut.fetch(request: HTTPRequest.builder.url("https//nothi.ng").build())
            #expect(result == data)
        } catch {
            Issue.record("Unexpected error")
        }
    }

}
