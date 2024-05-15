import XCTest
@testable import SmallCharacterModel

final class SmallCharacterModelTests: XCTestCase {
    
    let sourceName = "pirate-terms"
    var source: URL!
    var model: Model!
    
    override func setUp() {
        super.setUp()
        source = Bundle.module.url(forResource: sourceName, withExtension: "txt")
        model = Model.loadOrGenerate(name: sourceName, cohesion: 3, source: source)
    }
    
    override func tearDown() {
        source = nil
    }

    func test_generateWord() throws {
        for _ in 0...100 {
            let length = Int.random(in: 5...6)
            let word = try model.generateWord(length: length)
            print(word)
            XCTAssertEqual(word.count, length)
        }
    }
}
