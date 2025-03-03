import Foundation

public enum DataFetcherError: Error {
    case downloadFail(String)
}

public class DataFetcher {
    private var client: HTTPClient
    private let interceptors: [HTTPServiceRequestInterceptor]

    public init(client: HTTPClient = HTTPClient(), interceptors: [HTTPServiceRequestInterceptor] = []) {
        self.client = client
        self.interceptors = interceptors
    }

    public func fetch(request: HTTPRequest, interceptors: [HTTPServiceRequestInterceptor]) async throws -> Data {
        do {
            let data = try await client.requestData(request, interceptors: [], useCache: true)
            return data
        } catch {
            throw DataFetcherError.downloadFail(error.localizedDescription)
        }
    }
}
