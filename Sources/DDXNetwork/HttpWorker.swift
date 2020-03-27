import Foundation

public final class HttpWorker: HttpService {

    typealias RequestResult = Result<Data, Error>
    let urlSession: URLSession

    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func request(_ req: RequestModel,
                        additionalHeaders: [String: String] = [:],
                        completion: HttpCompletion?) {

        guard let urlRequest = makeRequest(req, additionalHeaders: additionalHeaders) else {
            let error = NSError(domain: "No request present", code: 1000, userInfo: nil)
            let result = RequestResult.failure(error)
            completion?(result)
            return
        }

        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if let err = error {
                completion?(Result.failure(err))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let info: [String: Any] = [ "error_message": "Error converting HTTPresponse" ]
                let error = NSError(domain: "Unknown Error", code: 601, userInfo: info)
                completion?(Result.failure(error))
                return
            }

            guard case 200..<300 = httpResponse.statusCode else {
                let errData = data ?? Data(count: 0)
                let message = String(data: errData, encoding: .utf8)
                let userInfo: [String: Any] = ["headers": httpResponse.allHeaderFields,
                                               "errorData": message ?? "No data"]

                let error = NSError(domain: "HTTP Error",
                                    code: httpResponse.statusCode,
                                    userInfo: userInfo)
                completion?(Result.failure(error))
                return
            }
            let responseData = data ?? Data(capacity: 0)
            completion?(RequestResult.success(responseData))
        }

        task.resume()
    }

    private func makeRequest(_ request: RequestModel,
                             additionalHeaders: HttpHeaders = [:]) -> URLRequest? {

        guard let url = URL(string: request.url) else { return nil }

        var newRequest = URLRequest(url: url,
                                    cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy,
                                    timeoutInterval: request.timeout)

        newRequest.httpMethod = request.method.rawValue

        request.headers.forEach { key, value in
            newRequest.addValue(value, forHTTPHeaderField: key)
        }

        additionalHeaders.forEach { key, value in
            newRequest.addValue(value, forHTTPHeaderField: key)
        }

        newRequest.httpBody = request.body
        return newRequest
    }
}
