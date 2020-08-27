import XCTest

//Comentário de teste

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DDXNetworkTests.allTests),
    ]
}
#endif
