import Foundation
import ComposableArchitecture

@Reducer
public struct ModelBuilder {
    
    @ObservableState
    public struct State: Equatable {
        public var name: String
        public var cohesion: Int
        public var source: URL
        public var progress: Double = 0
        public var runs: Set<Run> = []
        
        public init(name: String, cohesion: Int, source: URL) {
            self.name = name
            self.cohesion = cohesion
            self.source = source
        }
    }
    
    public enum Action {
        @CasePathable
        public enum Delegate {
            case progress(Double)
            case saved(response: Result<URL, Error>)
        }
        
        case delegate(Delegate)
        
        case generate
        case upsert(run: Run, progress: Double)
        case save
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .generate:
                return .run { [state = state] send in
                    let handle = try FileHandle(forReadingFrom: state.source)
                    
                    var buffer: String = ""

                    let attributes = try FileManager.default.attributesOfItem(atPath: state.source.path())
                    let fileSize = attributes[FileAttributeKey.size] as! UInt64
                    
                    var remainingBytes: UInt64 = fileSize
                    
                    while let data = try handle.read(upToCount: 1), !data.isEmpty {
                        
                        var follower: String?
                        
                        for encoding in String.Encoding.allCases {
                            if let out = String(data: data, encoding: encoding) {
                                follower = out
                                break
                            }
                        }
                        
                        guard let follower = follower else {
                            throw SourceError.failedToDecode(data)
                        }
                        
                        remainingBytes -= 1
                        
                        let progress = Double(remainingBytes) / Double(fileSize)
                        
                        if follower.firstIsWordChar {
                            let run = Run(letters: buffer, followers: [follower: 1])
                            await send(.upsert(run: run, progress: progress))
                            buffer = "\(buffer)\(follower)".tail(length: state.cohesion)
                        } else {
                            let run = Run(letters: buffer, followers: ["": 1])
                            await send(.upsert(run: run, progress: progress))
                            buffer = ""
                        }
                    }
                    
                    try handle.close()
                    await send(.save)
                }
            case .upsert(let run, let progress):
                state.runs.upsert(run: run)
                return .send(.delegate(.progress(progress)))
            case .save:
                return .run { [state = state] send in
                    do {
                        let data = try JSONEncoder().encode(state.runs)
                        let saveURL = try URL.defaultSaveURL(name: state.name, cohesion: state.cohesion)
                        try data.write(to: saveURL, options: .atomic)
                        await send(.delegate(.saved(response: .success(saveURL))))
                    } catch {
                        await send(.delegate(.saved(response: .failure(error))))
                    }
                }
            case .delegate:
                return .none
            }
        }
    }
}
