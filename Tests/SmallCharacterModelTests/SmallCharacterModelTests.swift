import Foundation
import Testing

@testable import SmallCharacterModel

struct SmallCharacterModelTests {
    
    var testSource: URL {
        Bundle.module.url(forResource: "test-set", withExtension: "txt")!
    }
    
    @Test
    func test_modelLoader() async throws {
        let source = TrainingDataSource(name: "test-set", cohesion: 3, sourceLocation: testSource)
        var sut = CharacterModelState(source: .trainingData(source))
        try loadFromApplicationSupport(name: "reset", cohesion: 3, source: testSource, state: &sut)
    }
    
    @Test
    func test_modelBuilder() async throws {
        var sut = ModelBuilderState(name: "reset", cohesion: 3, source: testSource)
        try generate(state: &sut)
        #expect(sut.progress != 0)
    }
    
    @Test
    func test_wordGenerator() async throws {
        let model = Model(name: "test-model", cohesion: 3, runs: [
            .init(letters: "", followers: ["a": 1]),
            .init(letters: "a", followers: ["a": 1, "": 1]),
            .init(letters: "aa", followers: ["a": 1, "": 1]),
            .init(letters: "aaa", followers: ["a": 1, "": 1]),
        ])
        
        let word = try generate(prefix: "", length: 3, model: model)
        #expect(word == "aaa")
    }
}
