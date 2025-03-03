import Foundation

public protocol HTTPServiceRequestInterceptor {
    var identifier: String { get }
    func intercept(request: URLRequest) -> URLRequest
}

