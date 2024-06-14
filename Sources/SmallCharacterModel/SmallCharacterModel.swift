import Foundation
import ComposableArchitecture

@Reducer
public struct SmallCharacterModel {
    
    public struct State: Equatable {
        var modelLoader: ModelLoader.State
        var modelBuilder: ModelBuilder.State?
        var wordGenerator: WordGenerator.State?
    }
    
    public enum Action {
        case modelLoader(ModelLoader.Action)
        case modelBuilder(ModelBuilder.Action)
        case wordGenerator(WordGenerator.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.modelLoader, action: \.modelLoader) {
            ModelLoader()
        }
        
        Reduce { state, action in
            switch action {
            case .modelLoader(.delegate(.loaded(let model))):
                state.wordGenerator = .init(model: model)
                return .none
            case .modelLoader(.delegate(.requestModelGeneration(let name, let cohesion, let source))):
                state.modelBuilder = .init(name: name, cohesion: cohesion, source: source)
                return .send(.modelBuilder(.generate))
            default:
                return .none
            }
        }
        .ifLet(\.modelBuilder, action: \.modelBuilder) {
            ModelBuilder()
        }
        .ifLet(\.wordGenerator, action: \.wordGenerator) {
            WordGenerator()
        }
    }
}
