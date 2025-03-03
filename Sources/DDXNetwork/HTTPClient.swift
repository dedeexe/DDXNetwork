import Foundation

public enum HTTPClientError: Error, Equatable {
    case invalidRequestURL
    case invalidResponse
    case httpError(Int, Data)
    case unknownError
    case decodingError(String)
}

public final class HTTPClient {
    let urlSession: HTTPClientURLSession
    let configuration: Configuration

    public init(
        urlSession: HTTPClientURLSession = URLSession.shared,
        configuration: Configuration = Configuration()
    ) {
        self.urlSession = urlSession
        self.configuration = configuration
    }

    public func requestData(
        _ request: HTTPRequest,
        additionalHeaders: [String: String] = [:],
        interceptors: [HTTPServiceRequestInterceptor],
        useCache: Bool = false
    ) async throws -> Data {
        let successRange = 200..<300
        let errorRange = 400..<600

        guard let urlRequest = makeRequest(request, additionalHeaders: additionalHeaders) else {
            throw HTTPClientError.invalidRequestURL
        }

        if useCache, let cachedResponse = configuration.cache.cachedResponse(for: urlRequest) {
            return cachedResponse.data
        }

        let intercepctorsList = configuration.interceptors + interceptors

        let interceptedRequest = intercepctorsList.reduce(urlRequest) { request, middleware in
            middleware.intercept(request: request)
        }

        let (data, response) = try await urlSession.data(for: interceptedRequest, delegate: nil)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        if case errorRange = httpResponse.statusCode {
            throw HTTPClientError.httpError(httpResponse.statusCode, data)
        }

        //There is a limbo here. No status code 300 range is being handled (signed Dede.exe) :D

        guard case successRange = httpResponse.statusCode else {
            throw HTTPClientError.unknownError
        }

        configuration.cache.storeCachedResponse(.init(response: response, data: data), for: urlRequest)
        return data
    }

    private func makeRequest(_ request: HTTPRequest,
                             additionalHeaders: HTTPRequest.Header = [:]) -> URLRequest? {

        guard let transientURL = URL(string: request.url) else {
            return nil
        }

        var urlComponents =  URLComponents(url: transientURL, resolvingAgainstBaseURL: true)
        let queryItems:[URLQueryItem] = request.parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }

        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            return nil
        }

        var newRequest = URLRequest(url: url,
                                    cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy,
                                    timeoutInterval: request.timeout)

        newRequest.httpMethod = request.method.rawValue

        request.header.forEach { key, value in
            newRequest.addValue(value, forHTTPHeaderField: key)
        }

        additionalHeaders.forEach { key, value in
            newRequest.addValue(value, forHTTPHeaderField: key)
        }

        return newRequest
    }
}

extension HTTPClient {
    public struct Configuration {
        var interceptors: [HTTPServiceRequestInterceptor] = []
        var cache: URLCache

        public init(
            interceptors: [HTTPServiceRequestInterceptor] = [],
            cache: URLCache = URLCache()
        ) {
            self.interceptors = interceptors
            self.cache = cache
        }

        mutating public func addInterceptor(_ interceptor: HTTPServiceRequestInterceptor) {
            interceptors.append(interceptor)
        }
    }
}
