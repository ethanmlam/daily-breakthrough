import WidgetKit
import SwiftUI

struct Entry: TimelineEntry {
    let date: Date
    let passage: Passage?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, passage: Passage(date: "", excerpt: "Today's passage appears here.", credit: "Author, Book", source: ""))
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: .now, passage: PassageStore.cached()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let passage = await PassageStore.refresh()
            let entry = Entry(date: .now, passage: passage)
            // Ask for a refresh a few minutes after the next local midnight.
            let cal = Calendar.current
            let midnight = cal.nextDate(after: .now, matching: DateComponents(hour: 0, minute: 5), matchingPolicy: .nextTime) ?? .now.addingTimeInterval(6 * 3600)
            completion(Timeline(entries: [entry], policy: .after(midnight)))
        }
    }
}

struct DailyWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: Entry

    var body: some View {
        if let p = entry.passage {
            VStack(alignment: .leading, spacing: 6) {
                Text(p.excerpt)
                    .font(.system(family == .systemSmall ? .caption : .footnote, design: .serif))
                    .minimumScaleFactor(0.5)
                Spacer(minLength: 0)
                Text(p.credit)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            Text("Open the app once to load today's passage.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct DailyWidget: Widget {
    let kind = "DailyBreakthroughWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Daily Breakthrough")
        .description("Today's passage on your home screen.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@main
struct DailyWidgetBundle: WidgetBundle {
    var body: some Widget { DailyWidget() }
}
