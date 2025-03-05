import Foundation

public enum RequestFetcherError: Error {
    case downloadFail(String)
    case decodingError(String)
}

public class RequestFetcher {
    private var fetcher: DataFetcher
    private var decoder: JSONDecoder?
    let interceptors: [HTTPServiceRequestInterceptor]

    let defaultDecoder: JSONDecoder = {
        JSONDecoder()
    }()

    public init(
        fetcher: DataFetcher = DataFetcher(),
        interceptors: [HTTPServiceRequestInterceptor],
        decoder: JSONDecoder? = nil
    ) {
        self.decoder = decoder
        self.fetcher = fetcher
        self.interceptors = interceptors
    }

    public func fetch<T: Decodable>(_ type: T.Type, request: HTTPRequest) async throws -> T {
        do {
            let data = try await fetcher.fetch(request: request, interceptors: interceptors)
            let decoder = self.decoder ?? defaultDecoder
            let object = try decoder.decode(type, from: data)
            return object
        } catch DataFetcherError.downloadFail(let message) {
            throw RequestFetcherError.downloadFail(message)
        } catch {
            let stringType = String(describing: type.self)
            throw RequestFetcherError.decodingError(stringType)
        }
    }
}
