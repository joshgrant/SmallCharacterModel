//
//  File.swift
//
//
//  Created by Me on 5/13/24.
//

import Foundation

public class Model: Codable {
    
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
    
    public static func loadOrGenerate(name: String, cohesion: Int = 3, source: URL) -> Model {
        do {
            let saveURL = try saveURL(name: name, cohesion: cohesion)
            let data = try Data(contentsOf: saveURL)
            return try JSONDecoder().decode(Model.self, from: data)
        } catch {
            do {
                return try generate(name: name, cohesion: cohesion, source: source)
            } catch {
                fatalError()
            }
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
    private func upsert(run: Run) {
        guard let match = self[run] else {
            runs.insert(run)
            return
        }
        
        match.followers.merge(run.followers, uniquingKeysWith: +)
    }
    
    private subscript(run: Run) -> Run? {
        runs.first { $0 == run }
    }
    
    private subscript(letters: String) -> Run? {
        runs.first { $0.letters == letters }
    }
    
    private static func saveURL(name: String, cohesion: Int) throws -> URL {
        var directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        directory.append(path: Bundle.main.bundleIdentifier ?? "SmallCharacterModel")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        directory.append(path: "\(name)_\(cohesion).model")
        return directory
    }
}

extension Model {
    
    public func generateWord(prefix: String = "", length: Int) throws -> String {
        
        var word = prefix
        /// The `key` is the suffix and the `value` are the letters to skip.
        var skips: [String: Set<String>] = [:]
        
        while true {
            let suffix = String(word.suffix(cohesion))
            guard let run = self[suffix] else {
                fatalError()
            }
            
            if word.count < length {
                skips[suffix] = (skips[suffix] ?? []).union([""])
            }
            
            guard let randomFollower = run.weightedRandomFollower(skipping: skips[suffix] ?? [], shouldTerminate: word.count == length) else {
                // We need to backtrack by dropping the last letter
                
                guard word.count > 0 else {
                    throw GenerationError.lengthIsIncompatibleWithModel
                }
                
                let last = String(word.removeLast())
                let lastSuffix = String(word.suffix(cohesion))
                skips[lastSuffix] = (skips[lastSuffix] ?? []).union([last])
                continue
            }
            
            // If we do find a valid random follower, reset the skips.
            if randomFollower == "" {
                break
            } else {
                word.append(randomFollower)
            }
        }
        
        return word
    }
}
