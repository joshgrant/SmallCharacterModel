import XCTest
import ComposableArchitecture

@testable import SmallCharacterModel

final class SmallCharacterModelTests: XCTestCase {
    
    var testSource: URL {
        Bundle.module.url(forResource: "test-set", withExtension: "txt")!
    }
    
    @MainActor
    func test_modelLoader() async {
        let store = TestStore(initialState: SmallCharacterModel.State(
            modelLoader: .init()
        )) {
            SmallCharacterModel()
        }
        store.exhaustivity = .off
        
        await store.send(.modelLoader(.loadOrGenerate(name: "test-set", cohesion: 3, source: testSource)))
        await store.receive(\.modelLoader.delegate.loaded, timeout: 5)
    }
    
    @MainActor
    func test_modelBuilder() async {
        let store = TestStore(initialState: ModelBuilder.State(name: "test-set", cohesion: 3, source: testSource)) {
            ModelBuilder()
        }
        store.exhaustivity = .off
        
        await store.send(.generate)
        await store.receive(\.upsert, timeout: 1)
        await store.receive(\.delegate.progress, timeout: 1)
    }
    
    @MainActor
    func test_wordGenerator() async {
        let model = Model(name: "test-model", cohesion: 3, runs: [
            .init(letters: "", followers: ["a": 1]),
            .init(letters: "a", followers: ["a": 1, "": 1]),
            .init(letters: "aa", followers: ["a": 1, "": 1]),
            .init(letters: "aaa", followers: ["a": 1, "": 1]),
        ])
        let store = TestStore(initialState: WordGenerator.State(model: model)) {
            WordGenerator()
        }
        
        await store.send(.generate(prefix: "", length: 3))
        await store.receive(\.delegate.newWord, "aaa")
    }
}
