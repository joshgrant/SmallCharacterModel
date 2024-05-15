import XCTest
@testable import SmallCharacterModel

final class SmallCharacterModelTests: XCTestCase {
    
    let sourceName = "male-names"
    var source: URL!
    
    override func setUp() {
        super.setUp()
        source = Bundle.module.url(forResource: sourceName, withExtension: "txt")
    }
    
    override func tearDown() {
        source = nil
    }
    
    func test_upsert() {
        let model = Model(name: "test", cohesion: 3)
        model.upsert(run: .init(wordSlice: "abcd"))
        model.upsert(run: .init(wordSlice: "abcd"))
        model.upsert(run: .init(wordSlice: "efgh"))
        model.upsert(run: .init(wordSlice: "ghik"))
        
        XCTAssertEqual(model["abc"]?.total, 2)
        XCTAssertEqual(model["abc"]?.followers, ["d": 2])
        XCTAssertEqual(model["efg"]?.followers, ["h": 1])
        XCTAssertEqual(model["ghi"]?.letters, "ghi")
        
        XCTAssertNil(model["lmo"])
    }
    
    func test_generateModel() throws {
        let model = try Model(name: sourceName, cohesion: 3, source: source)
        XCTAssertGreaterThan(model.runs.count, 0)
    }
    
    func test_generateWord() throws {
        let model = try Model(name: sourceName, cohesion: 3, source: source)
        for _ in 0...100 {
            let word = generateWord(model: model, length: 10)
            print(word)
//            XCTAssertEqual(word.count, 10)
        }
    }
}
