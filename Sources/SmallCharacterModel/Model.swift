//
//  File.swift
//
//
//  Created by Me on 5/13/24.
//

import Foundation

class Generation {
    
    let cohesion: Int
    
    init(cohesion: Int) {
        self.cohesion = cohesion
    }
    
    /// This represents the "choices" we've made along our journey from the root
    var path: [String] = []
    
    /// The key is the `word` - we ignore any followers in the value. This represents the branches we've
    /// taken that won't satisfy the criteria (length)
    var ignoring: [String: Set<String>] = [:]
    
    var word: String {
        path.joined()
    }
    
    var tail: String {
        path.suffix(cohesion).joined()
    }
    
    var last: String {
        path.last ?? ""
    }
    
    func ignore(letter: String, for word: String) {
        var ignoreSet: Set<String> = ignoring[word] ?? []
        ignoreSet.insert(letter)
        ignoring[word] = ignoreSet
    }
}

class Model: Codable {
    
    var name: String
    var cohesion: Int
    var runs: Set<Run>
    
    enum CodingKeys: String, CodingKey {
        case name = "n"
        case cohesion = "c"
        case runs = "r"
    }
    
    private init(name: String, cohesion: Int, runs: Set<Run>) {
        self.name = name
        self.cohesion = cohesion
        self.runs = runs
    }
    
    static func loadOrGenerate(name: String, cohesion: Int = 3, source: URL) throws -> Model {
        do {
            let saveURL = try saveURL(name: name, cohesion: cohesion)
            let data = try Data(contentsOf: saveURL)
            return try JSONDecoder().decode(Model.self, from: data)
        } catch {
            return try generate(name: name, cohesion: cohesion, source: source)
        }
    }
    
    private static func generate(name: String, cohesion: Int, source: URL) throws -> Model {
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

        let model = Model(name: name, cohesion: cohesion, runs: runs)
        try model.save()
        
        return model
    }
    
    private func save() throws {
        let data = try JSONEncoder().encode(self)
        let saveURL = try Self.saveURL(name: name, cohesion: cohesion)
        try data.write(to: saveURL, options: .atomic)
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
    
    static func saveURL(name: String, cohesion: Int) throws -> URL {
        var directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        directory.append(path: Bundle.main.bundleIdentifier ?? "SmallCharacterModel")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        directory.append(path: "\(name)_\(cohesion).model")
        return directory
    }
}

extension Model {
    
    func generateWord(prefix: String = "") -> String {
        
        var word = prefix
        
        while true {
            
            let suffix = word.suffix(cohesion)
            guard let run = runs.first(where: { $0.letters == suffix }) else {
                fatalError()
            }
            
            guard let randomFollower = run.weightedRandomFollower() else {
                // No followers
                fatalError()
            }
            
            if randomFollower == "" {
                break
            } else {
                word.append(randomFollower)
            }
        }
        
        return word
    }
}
