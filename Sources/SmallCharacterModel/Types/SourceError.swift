import Foundation

public enum SourceError: Error {
    case invalidSource(String)
    case failedToDecode(Data)
}
