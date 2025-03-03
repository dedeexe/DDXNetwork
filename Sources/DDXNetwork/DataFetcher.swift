import Foundation

public enum DataFetcherError: Error {
    case downloadFail(String)
}

public class DataFetcher {
    private var client: HTTPClient

    public init(client: HTTPClient = HTTPClient(configuration: HTTPClient.Configuration())) {
        self.client = client
    }

    public func fetch(request: HTTPRequest, interceptors: [HTTPServiceRequestInterceptor] = []) async throws -> Data {
        do {
            let data = try await client.requestData(request, interceptors: interceptors, useCache: true)
            return data
        } catch {
            throw DataFetcherError.downloadFail(error.localizedDescription)
        }
    }
}
