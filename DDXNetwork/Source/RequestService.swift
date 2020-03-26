public protocol RequestService {

    func requestData(from request: RequestModel,
                     additionalHeaders: HttpHeaders,
                     completion: HttpCompletion?)

    func request<T: Decodable>(_ type: T.Type,
                               from request: RequestModel,
                               additionalHeaders: HttpHeaders,
                               completion: ((Result<T, Error>) -> Void)?)

}
