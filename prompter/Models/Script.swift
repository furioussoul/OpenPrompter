import Foundation

struct Script: Codable, Identifiable {
    var id = UUID()
    var content: String
    var title: String
    var createdAt: Date
    
    static var defaultScript: Script {
        Script(
            content: "Welcome to OpenPrompter. Paste your script here and start recording! Adjust speed with Command +/- and play/pause with Space.",
            title: "Welcome Script",
            createdAt: Date()
        )
    }
}
