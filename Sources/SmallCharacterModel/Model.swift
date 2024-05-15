//
//  File.swift
//  
//
//  Created by Me on 5/13/24.
//

import Foundation

class Model: Codable {
    
    var name: String
    var cohesion: Int
    var runs: Set<Run>
    
    enum CodingKeys: String, CodingKey {
        case name = "n"
        case cohesion = "c"
        case runs = "r"
    }
    
    init(name: String, cohesion: Int, runs: Set<Run> = []) {
        self.name = name
        self.cohesion = cohesion
        self.runs = runs
    }
    
    convenience init(name: String, cohesion: Int, source: URL) throws {
        let handle = try FileHandle(forReadingFrom: source)
        
        var buffer: String = ""
        var runs: Set<Run> = []
        
        while let data = try handle.read(upToCount: 1), !data.isEmpty {
            
            guard let follower = String(data: data, encoding: .utf8)?.localizedLowercase else {
                throw SourceError.failedToDecode(data)
            }
            
            if follower.firstIsWordChar {
                let run = Run(letters: buffer, followers: [follower: 1])
                runs.upsert(run: run)
                buffer = "\(buffer)\(follower)".tail(length: cohesion)
            } else {
                let run = Run(letters: buffer, followers: ["": 1])
                runs.upsert(run: run)
                buffer = ""
            }
        }
        
        try handle.close()
        
        self.init(name: name, cohesion: cohesion, runs: runs)
    }
    
    static func load(name: String) throws -> Model {
        let source = try urlForModel(name: name, cohesion: 3)
        let data = try Data(contentsOf: source)
        return try JSONDecoder().decode(Model.self, from: data)
    }
    
    /// If the run already exists, add the followers and increment the total
    /// If the run doens't exist, simply insert it
    func upsert(run: Run) {
        guard let match = self[run] else {
            runs.insert(run)
            return
        }
        
        match.followers.merge(run.followers, uniquingKeysWith: +)
        match.total += run.total
    }
    
    subscript(run: Run) -> Run? {
        runs.first { $0 == run }
    }
    
    subscript(letters: String) -> Run? {
        runs.first { $0.letters == letters }
    }
}
