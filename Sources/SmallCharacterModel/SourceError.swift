import Foundation

enum SourceError: Error {
    case invalidSource(String)
    case failedToDecode(Data)
}
