import Foundation

public struct HTTPRequest {
    public internal(set) var url: String
    public internal(set) var method: Method
    public internal(set) var parameters: Parameters
    public internal(set) var header: Header
    public internal(set) var body: Body?
    public internal(set) var timeout: TimeInterval

    // MARK: - Static Methosd
    static public var builder: HTTPRequestBuilder {
        HTTPRequestBuilder()
    }

    // MARK: - Declarations
    public typealias Body = Data
    public typealias Header = [String: String]
    public typealias Parameters = [String: String]

    public init(
        url: String,
        method: Method = .get,
        parameters: Parameters = [:],
        header: Header = [:],
        body: Body? = nil,
        timeout: TimeInterval = 30.0
    ) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.header = header
        self.body = body
        self.timeout = timeout
    }

    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
}

public class HTTPRequestBuilder {
    private var request = HTTPRequest(url: "")

    public func url(_ value: String) -> HTTPRequestBuilder {
        request.url = value
        return self
    }

    public func method(_ value: HTTPRequest.Method) -> HTTPRequestBuilder {
        request.method = value
        return self
    }

    public func body(_ value: HTTPRequest.Body?) -> HTTPRequestBuilder {
        request.body = value
        return self
    }

    public func header(key: String, value: String?) -> HTTPRequestBuilder {
        request.header[key] = value
        return self
    }

    public func paramter(key: String, value: String?) -> HTTPRequestBuilder {
        request.parameters[key] = value
        return self
    }

    public func timeout(_ value: TimeInterval) -> HTTPRequestBuilder {
        request.timeout = value
        return self
    }

    public func build() -> HTTPRequest{
        request
    }
}
