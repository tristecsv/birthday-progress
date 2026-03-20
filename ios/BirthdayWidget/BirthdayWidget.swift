import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BirthdayEntry {
        BirthdayEntry(date: Date(), day: 1, month: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (BirthdayEntry) -> Void) {
        let entry = BirthdayEntry(date: Date(), day: 1, month: 1)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BirthdayEntry>) -> Void) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.birthdayProgress")
        let day = userDefaults?.integer(forKey: "birthday_day") ?? 1
        let month = userDefaults?.integer(forKey: "birthday_month") ?? 1
        let actualDay = day == 0 ? 1 : day
        let actualMonth = month == 0 ? 1 : month
        
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let entry = BirthdayEntry(date: Date(), day: actualDay, month: actualMonth)
        
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

struct BirthdayEntry: TimelineEntry {
    let date: Date
    let day: Int
    let month: Int
}

struct BirthdayWidgetEntryView : View {
    var entry: Provider.Entry

    var progress: Double {
        let now = Date()
        let calendar = Calendar.current
        
        var nextComponents = calendar.dateComponents([.year], from: now)
        nextComponents.month = entry.month
        nextComponents.day = entry.day
        nextComponents.hour = 0
        nextComponents.minute = 0
        nextComponents.second = 0
        
        var nextBirthday = calendar.date(from: nextComponents) ?? now
        // if nextBirthday has already passed today, advance year
        if nextBirthday < calendar.startOfDay(for: now) {
            nextBirthday = calendar.date(byAdding: .year, value: 1, to: nextBirthday) ?? nextBirthday
        }
        
        let lastBirthday = calendar.date(byAdding: .year, value: -1, to: nextBirthday) ?? now
        
        let totalTime = nextBirthday.timeIntervalSince(lastBirthday)
        let elapsed = now.timeIntervalSince(lastBirthday)
        
        if totalTime <= 0 { return 0 }
        let p = elapsed / totalTime
        return min(max(p, 0.0), 1.0)
    }

    var percentage: Int {
        Int(progress * 100)
    }

    var daysRemaining: Int {
        let now = Date()
        let calendar = Calendar.current
        
        var nextComponents = calendar.dateComponents([.year], from: now)
        nextComponents.month = entry.month
        nextComponents.day = entry.day
        nextComponents.hour = 0
        nextComponents.minute = 0
        nextComponents.second = 0
        
        var nextBirthday = calendar.date(from: nextComponents) ?? now
        if nextBirthday < calendar.startOfDay(for: now) {
            nextBirthday = calendar.date(byAdding: .year, value: 1, to: nextBirthday) ?? nextBirthday
        }
        
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: nextBirthday)
        return components.day ?? 0
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .trim(from: 0, to: 240.0 / 360.0)
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(150))
                .padding(16)
            
            // Progress
            Circle()
                .trim(from: 0, to: (240.0 / 360.0) * progress)
                .stroke(Color(red: 47/255, green: 128/255, blue: 237/255), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(150))
                .padding(16)
            
            VStack(spacing: 4) {
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
                
                Text("\(percentage)%")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("\(daysRemaining) días")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            .offset(y: 20)
        }
    }
}

struct BirthdayWidget: Widget {
    let kind: String = "BirthdayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BirthdayWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color(UIColor.systemBackground)
                    }
            } else {
                BirthdayWidgetEntryView(entry: entry)
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("Cumpleaños")
        .description("Tu progreso hacia el próximo cumpleaños.")
        .supportedFamilies([.systemSmall])
    }
}
