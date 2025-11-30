//
//  Top.swift
//  SmallCharacterModel
//
//  Created by Joshua Grant on 11/30/25.
//

import Foundation

struct SmallCharacterModel {
    
    public static func generate(
        state: inout ModelBuilderState
    ) throws {
        let handle = try FileHandle(forReadingFrom: state.source)
        
        var buffer: String = ""
        
        let attributes = try FileManager.default.attributesOfItem(atPath: state.source.path())
        let fileSize = attributes[FileAttributeKey.size] as! UInt64
        
        var remainingBytes: UInt64 = fileSize
        
        while let data = try handle.read(upToCount: 1), !data.isEmpty {
            
            var follower: String?
            
            for encoding in String.Encoding.allCases {
                if let out = String(data: data, encoding: encoding) {
                    follower = out
                    break
                }
            }
            
            guard let follower = follower else {
                throw SourceError.failedToDecode(data)
            }
            
            remainingBytes -= 1
            
            let progress = Double(fileSize - remainingBytes) / Double(fileSize)
            
            if follower.firstIsWordChar {
                let run = Run(letters: buffer, followers: [follower: 1])
                upsert(run: run, progress: progress, state: &state)
                buffer = "\(buffer)\(follower)".tail(length: state.cohesion)
            } else {
                let run = Run(letters: buffer, followers: ["": 1])
                upsert(run: run, progress: progress, state: &state)
                buffer = ""
            }
        }
        
        try handle.close()
        try save(state: state)
    }
    
    public static func upsert(
        run: Run,
        progress: Double,
        state: inout ModelBuilderState
    ) {
        state.progress = progress
        state.runs.upsert(run: run)
    }
    
    public static func save(
        state: ModelBuilderState
    ) throws {
        let data = try JSONEncoder().encode(state.runs)
        let saveURL = try URL.defaultSaveURL(name: state.name, cohesion: state.cohesion)
        try data.write(to: saveURL, options: .atomic)
    }
    
    public static func loadFromApplicationSupport(
        name: String,
        cohesion: Int,
        source: URL,
        state: inout CharacterModelState
    ) throws {
        do {
            let saveURL = try URL.defaultSaveURL(name: name, cohesion: cohesion)
            try loadModelDirectly(name: name, cohesion: cohesion, source: saveURL, state: &state)
        } catch {
            var modelBuilder = ModelBuilderState(name: name, cohesion: cohesion, source: source)
            try generate(state: &modelBuilder)
            state.modelBuilder = modelBuilder
        }
    }
    
    public static func loadModelDirectly(
        name: String,
        cohesion: Int,
        source: URL,
        state: inout CharacterModelState
    ) throws {
        let data = try Data(contentsOf: source)
        let runs = try JSONDecoder().decode(Set<Run>.self, from: data)
        state.model = .init(name: name, cohesion: cohesion, runs: runs)
    }
    
    public static func findRandomElement(
        _ elements: [String: Int],
        _ skipping: Set<String>,
        _ shouldTerminate: Bool
    ) -> String? {
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
    
    public static func load(
        state: inout CharacterModelState
    ) throws {
        switch state.source {
        case .preTrainedBundleModel(let source):
            let bundleURL = Bundle.main.url(
                forResource: "\(source.name)_\(source.cohesion)",
                withExtension: source.fileExtension)!
            try loadModelDirectly(
                name: source.name,
                cohesion: source.cohesion,
                source: bundleURL,
                state: &state)
        case .trainingData(let source):
            try loadFromApplicationSupport(
                name: source.name,
                cohesion: source.cohesion,
                source: source.sourceLocation,
                state: &state)
        }
    }
    
    public static func generate(
        prefix: String,
        length: Int,
        model: Model
    ) throws -> String {
        var word = prefix
        /// The `key` is the suffix and the `value` are the letters to skip
        var skips: [String: Set<String>] = [:]
        
        while true {
            let suffix = String(word.suffix(model.cohesion))
            guard let run = model[suffix] else {
                fatalError()
            }
            
            if word.count < length {
                skips[suffix] = (skips[suffix] ?? []).union([""])
            }
            
            guard let randomFollower = findRandomElement(run.followers, skips[suffix] ?? [], word.count >= length) else {
                // We need to backtrack by dropping the last letter
                
                guard word.count > 0 else {
                    throw GenerationError.lengthIsIncompatibleWithModel
                }
                
                let last = String(word.removeLast())
                let lastSuffix = String(word.suffix(model.cohesion))
                skips[lastSuffix] = (skips[lastSuffix] ?? []).union([last])
                continue
            }
            
            // If we do find a valid random follower, reset the skips
            if randomFollower == "" {
                break
            } else {
                word.append(randomFollower)
            }
        }
        
        return word
    }
    
}
