//
//  File.swift
//  
//
//  Created by Me on 6/14/24.
//

import Foundation

public struct Model: Equatable, Codable {
    public var name: String
    public var cohesion: Int
    public var runs: Set<Run>
    
    enum CodingKeys: String, CodingKey {
        case name = "n"
        case cohesion = "c"
        case runs = "r"
    }
    
    subscript(run: Run) -> Run? {
        runs.first { $0 == run }
    }
    
    subscript(letters: String) -> Run? {
        runs.first { $0.letters == letters }
    }
}
