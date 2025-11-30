import Foundation

public struct ModelBuilderState: Equatable {
    
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
