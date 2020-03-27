import Foundation

public typealias HttpResult = Result<Data, Error>
public typealias HttpCompletion = (HttpResult) -> Void

public protocol HttpService {

    func request(_ req: RequestModel,
                 additionalHeaders: HttpHeaders,
                 completion: HttpCompletion?)

}
