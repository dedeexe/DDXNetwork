import Foundation

struct MockObject: Codable, Equatable {
    var string: String
    var value: Int
}

extension MockObject {
    static var data: Data {
        let encoder = JSONEncoder()
        let object = MockObject(string: "String", value: 42)
        do {
            return try encoder.encode(object)
        } catch {
            return Data(count: 1)
        }
    }
}
