import XCTest
@testable import SmallCharacterModel

final class SmallCharacterModelTests: XCTestCase {
    
    let sourceName = "shakespeare"
    var source: URL!
    var model: Model!
    
    override func setUp() {
        super.setUp()
        source = Bundle.module.url(forResource: sourceName, withExtension: "txt")
        model = try! Model.loadOrGenerate(name: sourceName, cohesion: 3, source: source)
    }
    
    override func tearDown() {
        source = nil
    }

    func test_generateWord() throws {
        for _ in 0...100 {
            let word = model.generateWord()
            print(word)
        }
    }
}
