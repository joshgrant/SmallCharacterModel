import Foundation

extension URL {
    
    public static func defaultSaveURL(name: String, cohesion: Int) throws -> URL {
        var directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        directory.append(path: Bundle.main.bundleIdentifier ?? "SmallCharacterModel")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        directory.append(path: "\(name)_\(cohesion).model")
        return directory
    }
}
