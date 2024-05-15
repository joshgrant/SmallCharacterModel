//
//  File.swift
//  
//
//  Created by Me on 5/13/24.
//

import Foundation

extension String {
    
    func tail(length: Int) -> String {
        let start = index(
            endIndex,
            offsetBy: -length,
            limitedBy: startIndex) ?? startIndex
        return String(self[start ..< endIndex])
    }
    
    var firstIsWordChar: Bool {
        guard let first = first else {
            return false
        }
        
        return first.isLetter || first.isNumber || first == "'" || first == "-"
    }
}
