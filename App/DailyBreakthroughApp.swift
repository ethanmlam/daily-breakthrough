import SwiftUI
import WidgetKit

@main
struct DailyBreakthroughApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var passage: Passage? = PassageStore.cached() ?? Self.seed()
    @State private var loading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let p = passage {
                        Text(p.date).font(.caption).foregroundStyle(.secondary)
                        Text(p.excerpt).font(.system(.title3, design: .serif)).lineSpacing(6)
                        Text(p.credit).font(.footnote).foregroundStyle(.secondary)
                        Text(p.source).font(.footnote).foregroundStyle(.tertiary)
                    } else {
                        Text("No passage yet. Pull to refresh.").foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .refreshable { await reload() }
            .navigationTitle("Today")
        }
        .task { await reload() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await reload() } }
        }
    }

    private func reload() async {
        guard !loading else { return }
        loading = true
        defer { loading = false }
        if let p = await PassageStore.refresh() {
            passage = p
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private static func seed() -> Passage? {
        guard let url = Bundle.main.url(forResource: "SeedPassage", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Passage.self, from: data)
    }
}
