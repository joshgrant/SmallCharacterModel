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

extension String.Encoding: CaseIterable {
    
    public static var allCases: [String.Encoding] {
        [
            .utf8,
            .ascii,
            .iso2022JP,
            .isoLatin1,
            .isoLatin2,
            .japaneseEUC,
            .macOSRoman,
            .nextstep,
            .nonLossyASCII,
            .shiftJIS,
            .symbol,
            .unicode,
            .utf16,
            .utf16BigEndian,
            .utf16LittleEndian,
            .utf32,
            .utf32BigEndian,
            .utf32LittleEndian,
            .windowsCP1250,
            .windowsCP1251,
            .windowsCP1252,
            .windowsCP1253,
            .windowsCP1254
        ]
    }
}
