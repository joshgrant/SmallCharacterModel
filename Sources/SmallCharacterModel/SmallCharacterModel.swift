import Foundation

enum SourceError: Error {
    case invalidSource(String)
    case failedToDecode(Data)
}

func generateWord(model: Model, length: Int, prefix: String = "") -> String {
    
    var word = prefix.localizedLowercase
    var runs = model.runs
    
    while word.count < length {
        
        guard runs.count > 0 else {
            return word
        }
        
        // TODO: Somehow can we backtrack? As in, mark certain "branches" as traversed
        // so that we don't revisit them
        
        let tail = word.tail(length: model.cohesion)
        
        if let run = runs.first(where: { $0.letters == tail }) {
            if let follower = randomFollower(in: run, terminating: word.count >= length) {
                
                if follower.isEmpty {
                    return word
                } else {
                    word.append(follower)
                }
            } else {
                // Without any followers, this run is a dead branch. Remove it 
                // from the runs set
                runs.remove(run)
                
                // Because the run isn't valid, we also need to trim the tail 
                // to step back up the tree
                word.removeLast()
            }
        } else {
            // There wasn't any matching run! That means that our word is invalid
            // Let's drop back a level
            word.removeLast()
        }
    }
    
    return word
}

//func generateWord(model: Model, length: Int, characters: String = "") -> String {
//    let word = generateWordHelper(model: model, length: length, characters: characters)
//    return word.trimmingCharacters(in: .whitespacesAndNewlines)
//}
//
//func generateWordHelper(model: Model, length: Int, characters: String = "") -> String {
//
//    let tail = characters.tail(length: model.cohesion)
//    
//    guard let run = model[tail] else {
//        assertionFailure("The tail should exist in the data set, even if it has no followers: \(characters)")
//        return characters
//    }
//    
//    // TODO: We need to backtrack as it's the most efficient way...
//    // Maybe imperative backtracking would be easier because it's less memory intensive
//    //
//    guard let randomFollower = randomFollower(in: run, terminating: characters.count >= length) else {
//        return characters
//    }
//    
//    if randomFollower.isEmpty {
//        return characters
//    }
//    
//    return generateWord(model: model, length: length, characters: "\(characters)\(randomFollower)")
//}

func randomFollower(in run: Run, terminating: Bool) -> String? {
    
    if terminating && run.followers.contains(where: { $0.key.isEmpty }) {
        return ""
    }

    var randomValue = Int.random(in: 0 ... run.total)
    
    for (string, count) in run.followers {
        // If we're not terminating, don't select an empty character
        if randomValue <= count {
            if string.isEmpty {
                randomValue -= count
            } else {
                return string
            }
        } else {
            randomValue -= count
        }
    }
    
    return nil
}
