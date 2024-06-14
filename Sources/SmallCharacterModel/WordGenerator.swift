import Foundation
import ComposableArchitecture

@Reducer
public struct WordGenerator {
    
    public struct State: Equatable {
        var model: Model
    }
    
    public enum Action {
        @CasePathable
        enum Delegate {
            case newWord(String)
        }
        
        case delegate(Delegate)
        
        case generate(prefix: String, length: Int)
    }
    
    @Dependency(\.randomElementFinder) var randomElementFinder
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .generate(let prefix, let length):
                return .run { [model = state.model, cohesion = state.model.cohesion] send in
                    var word = prefix
                    /// The `key` is the suffix and the `value` are the letters to skip
                    var skips: [String: Set<String>] = [:]
                    
                    while true {
                        let suffix = String(word.suffix(cohesion))
                        guard let run = model[suffix] else {
                            fatalError()
                        }
                        
                        if word.count < length {
                            skips[suffix] = (skips[suffix] ?? []).union([""])
                        }
                        
                        guard let randomFollower = randomElementFinder.findRandomElement(run.followers, skips[suffix] ?? [], word.count >= length) else {
                            // We need to backtrack by dropping the last letter
                            
                            guard word.count > 0 else {
                                throw GenerationError.lengthIsIncompatibleWithModel
                            }
                            
                            let last = String(word.removeLast())
                            let lastSuffix = String(word.suffix(cohesion))
                            skips[lastSuffix] = (skips[lastSuffix] ?? []).union([last])
                            continue
                        }
                        
                        // If we do find a valid random follower, reset the skips
                        if randomFollower == "" {
                            break
                        } else {
                            word.append(randomFollower)
                        }
                    }
                    
                    await send(.delegate(.newWord(word)))
                }
            case .delegate:
                return .none
            }
        }
    }
}
