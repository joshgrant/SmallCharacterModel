import Foundation

enum SourceError: Error {
    case invalidSource(String)
    case failedToDecode(Data)
}

enum GenerationError: Error {
    case lengthIsIncompatibleWithModel
}
