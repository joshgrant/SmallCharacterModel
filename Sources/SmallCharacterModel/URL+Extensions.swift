//
//  File.swift
//  
//
//  Created by Me on 5/13/24.
//

import Foundation

func urlForModel(name: String, cohesion: Int) throws -> URL {
    var directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    directory.append(component: Bundle.main.bundleIdentifier ?? "com.bcelabs.CharBoy")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    directory.append(path: "\(name)_\(cohesion).model")
    return directory
}

func urlForSource(name: String) throws -> URL {
    guard let source = Bundle.main.url(forResource: name, withExtension: "txt") else {
        throw SourceError.invalidSource(name)
    }
    
    return source
}
