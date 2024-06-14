import Foundation

extension Set where Element == Run {
    
    mutating func upsert(run: Run) {
        if let match = first(where: { $0.letters == run.letters }) {
            match.followers.merge(run.followers, uniquingKeysWith: +)
        } else {
            insert(run)
        }
    }
}
