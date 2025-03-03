import Foundation

public enum RequestFetcherError: Error {
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
        fecther: DataFetcher = DataFetcher(),
        interceptors: [HTTPServiceRequestInterceptor],
        decoder: JSONDecoder? = nil
    ) {
        self.decoder = decoder
        self.fetcher = fecther
        self.interceptors = interceptors
    }

    public func fetch<T: Decodable>(_ type: T.Type, request: HTTPRequest) async throws -> T {
        let data = try await fetcher.fetch(request: request, interceptors: interceptors)

        do {
            let decoder = self.decoder ?? defaultDecoder
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            let stringType = String(describing: type.self)
            throw RequestFetcherError.decodingError(stringType)
        }
    }
}
