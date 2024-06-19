import Foundation
import ComposableArchitecture

@Reducer
public struct SmallCharacterModel {
    
    public struct PreTrainedBundleModelSource: Equatable {
        var name: String
        var cohesion: Int
        var fileExtension: String
        
        public init(name: String, cohesion: Int, fileExtension: String) {
            self.name = name
            self.cohesion = cohesion
            self.fileExtension = fileExtension
        }
    }
    
    public struct TrainingDataSource: Equatable {
        var name: String
        var cohesion: Int
        var sourceLocation: URL
        
        public init(name: String, cohesion: Int, sourceLocation: URL) {
            self.name = name
            self.cohesion = cohesion
            self.sourceLocation = sourceLocation
        }
    }
    
    public enum ModelSource: Equatable {
        case preTrainedBundleModel(PreTrainedBundleModelSource)
        case trainingData(TrainingDataSource)
    }
    
    public struct State: Equatable {
        public var source: ModelSource
        
        public var modelLoader: ModelLoader.State
        public var modelBuilder: ModelBuilder.State?
        public var wordGenerator: WordGenerator.State?
        
        public init(source: ModelSource) {
            self.source = source
            self.modelLoader = .init()
        }
    }
    
    public enum Action {
        @CasePathable
        public enum Delegate {
            case modelLoaded
        }
        
        case delegate(Delegate)
        
        case load
        
        case modelLoader(ModelLoader.Action)
        case modelBuilder(ModelBuilder.Action)
        case wordGenerator(WordGenerator.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                switch state.source {
                case .preTrainedBundleModel(let source):
                    let bundleURL = Bundle.main.url(
                        forResource: "\(source.name)_\(source.cohesion)",
                        withExtension: source.fileExtension)!
                    return .send(.modelLoader(.loadModelDirectly(
                        name: source.name,
                        cohesion: source.cohesion,
                        source: bundleURL)))
                case .trainingData(let source):
                    return .send(.modelLoader(.loadFromApplicationSupport(
                        name: source.name,
                        cohesion: source.cohesion,
                        source: source.sourceLocation)))
                }
            case .modelLoader(.delegate(.loaded(let name, let cohesion, let runs))):
                state.wordGenerator = .init(model: .init(name: name, cohesion: cohesion, runs: runs))
                return .send(.delegate(.modelLoaded))
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
        
        Scope(state: \.modelLoader, action: \.modelLoader) {
            ModelLoader()
        }
    }
}
