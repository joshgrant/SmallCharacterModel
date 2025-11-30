import Foundation

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
