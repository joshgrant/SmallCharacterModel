import Foundation
import ComposableArchitecture

@Reducer
public struct ModelLoader {
    
    @ObservableState
    public struct State: Equatable {}
    
    public enum Action {
        
        @CasePathable
        public enum Delegate {
            case modelLoadingFailed(Error)
            case loaded(name: String, cohesion: Int, runs: Set<Run>)
            case requestModelGeneration(name: String, cohesion: Int, source: URL)
        }
        
        case delegate(Delegate)
        case loadFromApplicationSupport(name: String, cohesion: Int, source: URL)
        case loadModelDirectly(name: String, cohesion: Int, source: URL)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .loadFromApplicationSupport(let name, let cohesion, let source):
                return .run { send in
                    do {
                        let saveURL = try URL.defaultSaveURL(name: name, cohesion: cohesion)
                        let data = try Data(contentsOf: saveURL)
                        let runs = try JSONDecoder().decode(Set<Run>.self, from: data)
                        await send(.delegate(.loaded(name: name, cohesion: cohesion, runs: runs)))
                    } catch {
                        // Model loading failed (likely because the model didn't exist)
                        // In this case, we need to generate the model
                        await send(.delegate(.requestModelGeneration(name: name, cohesion: cohesion, source: source)))
                    }
                }
            case .loadModelDirectly(let name, let cohesion, let source):
                return .run { send in
                    do {
                        let data = try Data(contentsOf: source)
                        let runs = try JSONDecoder().decode(Set<Run>.self, from: data)
                        await send(.delegate(.loaded(name: name, cohesion: cohesion, runs: runs)))
                    } catch {
                        // Model loading failed (likely because the model didn't exist)
                        // In this case, we need to generate the model
                        await send(.delegate(.modelLoadingFailed(error)))
                    }
                }
            }
        }
    }
}
