import Foundation

public typealias HttpHeaders = [String: String]
public typealias HttpParameters = [String: Any]
public typealias HttpBody = Data

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
