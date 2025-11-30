import Foundation

public struct CharacterModelState: Equatable {
    public var source: ModelSource
    
    public var modelBuilder: ModelBuilderState?
    public var model: Model?
    
    public init(source: ModelSource) {
        self.source = source
    }
}
