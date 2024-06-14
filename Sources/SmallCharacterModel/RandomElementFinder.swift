import Foundation
import ComposableArchitecture

public struct RandomElementFinder {
    var findRandomElement: (_ elements: [String: Int], _ skipping: Set<String>, _ shouldTerminate: Bool) -> String?
}

public extension RandomElementFinder: DependencyKey {
    
    static var liveValue: RandomElementFinder = .init { elements, skipping, shouldTerminate in
        if shouldTerminate {
            if elements.contains(where: { $0.key == "" }) {
                return ""
            } else {
                return nil
            }
        }
        
        let filteredFollowers = elements.filter {
            !skipping.contains($0.key)
        }
        
        let total = filteredFollowers.reduce(0) { partialResult, follower in
            if skipping.contains(follower.key) { return partialResult }
            return partialResult + follower.value
        }
        
        guard total > 0 else { return nil }
        
        var random = Int.random(in: 0 ... total)
        
        for follower in filteredFollowers {
            if follower.value >= random {
                return follower.key
            } else {
                random -= follower.value
            }
        }
        
        return nil
    }
    
    static var testValue: RandomElementFinder = .init { elements, skipping, shouldTerminate in
        if shouldTerminate {
            return ""
        } else {
            return "a"
        }
    }
}

public extension DependencyValues {
    
    var randomElementFinder: RandomElementFinder {
        get { self[RandomElementFinder.self] }
        set { self[RandomElementFinder.self] = newValue }
    }
}
