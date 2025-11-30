import Foundation

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
