//
//  File.swift
//  
//
//  Created by Me on 5/13/24.
//

import Foundation

class Run: Codable {
    
    var letters: String
    var followers: [String: Int]
    var total: Int
    
    enum CodingKeys: String, CodingKey {
        case letters = "l"
        case followers = "f"
        case total = "t"
    }
    
    /// A `wordSlice` contains `n+1` letters, where `n` is the window size, and the additional letter
    /// is the follower.
    init(wordSlice: String) {
        if wordSlice.count == 1 {
            self.letters = ""
            self.followers = [wordSlice: 1]
            self.total = 1
        } else {
            
            let sliceStart = wordSlice.startIndex
            let sliceEnd = wordSlice.index(before: wordSlice.endIndex)
            let windowEnd = wordSlice.index(before: sliceEnd)
            
            let letters = String(wordSlice[sliceStart ... windowEnd])
            let follower = String(wordSlice[sliceEnd])
            
            self.letters = letters
            self.followers = [follower: 1]
            self.total = 1
        }
    }
    
    init(letters: String, followers: [String: Int]) {
        self.letters = letters
        self.followers = followers
        self.total = followers.reduce(0, { partialResult, pair in
            partialResult + pair.value
        })
    }
}

extension Run: Hashable {
    
    static func ==(lhs: Run, rhs: Run) -> Bool {
        lhs.letters == rhs.letters
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(letters)
    }
}

extension Run: CustomStringConvertible {
    
    var description: String {
        "\(letters): \(followers)"
    }
}
