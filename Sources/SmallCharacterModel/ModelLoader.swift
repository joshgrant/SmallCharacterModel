import Foundation
import ComposableArchitecture

@Reducer
public struct ModelLoader {
    
    @ObservableState
    public struct State: Equatable {}
    
    public enum Action {
        
        @CasePathable
        public enum Delegate {
            case loaded(Model)
            case requestModelGeneration(name: String, cohesion: Int, source: URL)
        }
        
        case delegate(Delegate)
        case loadOrGenerate(name: String, cohesion: Int, source: URL)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .loadOrGenerate(let name, let cohesion, let source):
                return .run { send in
                    do {
                        let saveURL = try URL.defaultSaveURL(name: name, cohesion: cohesion)
                        let data = try Data(contentsOf: saveURL)
                        let model = try JSONDecoder().decode(Model.self, from: data)
                        await send(.delegate(.loaded(model)))
                    } catch {
                        // Model loading failed (likely because the model didn't exist)
                        // In this case, we need to generate the model
                        await send(.delegate(.requestModelGeneration(name: name, cohesion: cohesion, source: source)))
                    }
                }
            }
        }
    }
}
