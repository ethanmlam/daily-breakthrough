import Foundation

struct Passage: Codable, Equatable {
    var date: String
    var excerpt: String
    var credit: String
    var source: String
}

enum AppConfig {
    static var appGroupID: String {
        Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String ?? ""
    }
    static var feedURL: URL? {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "FeedURL") as? String else { return nil }
        return URL(string: s)
    }
}

enum PassageStore {
    private static let cacheKey = "cachedPassage"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: AppConfig.appGroupID)
    }

    static func cached() -> Passage? {
        guard let data = defaults?.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(Passage.self, from: data)
    }

    static func save(_ passage: Passage) {
        if let data = try? JSONEncoder().encode(passage) {
            defaults?.set(data, forKey: cacheKey)
        }
    }

    /// Fetches the feed. On success caches and returns it. On failure returns
    /// the last cached passage, or nil if there is none.
    static func refresh() async -> Passage? {
        if let url = AppConfig.feedURL {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                    let passage = try JSONDecoder().decode(Passage.self, from: data)
                    save(passage)
                    return passage
                }
            } catch {
                // fall through to cache
            }
        }
        return cached()
    }
}
