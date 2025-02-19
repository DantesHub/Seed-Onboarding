import Foundation
import WidgetKit

struct Provider: TimelineProvider {
    static let smallWidgetKind = "smallWidget"
    static let mediumWidgetKind = "mediumWidget"
    
    let data = DataService()
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> Entry {
        createEntry(for: Date(), in: context)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = createEntry(for: Date(), in: context)
        print("Getting snapshot for widget kind:", context.family == .systemSmall ? "smallWidget" : "mediumWidget")
        print("Pro status in snapshot:", data.isPro)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        print("Getting timeline for widget kind:", context.family == .systemSmall ? "smallWidget" : "mediumWidget")
        print("Pro status in timeline:", data.isPro)
        
        let currentDate = Date()
        var entries: [Entry] = []
        
        for offset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: offset, to: currentDate)!
            entries.append(createEntry(for: entryDate, in: context))
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func createEntry(for date: Date, in context: Context) -> Entry {
        let endOfDay = Calendar.current.startOfDay(for: date).addingTimeInterval(24 * 60 * 60)
        let remainingTime = endOfDay.timeIntervalSince(date)
        let isSmallWidget = context.family == .systemSmall

        var currentQuote = ""
        currentQuote = fetchQuote()
        if isSmallWidget {
            while currentQuote.count > 55 {
                currentQuote = fetchQuote()
            }
        }

        // Determine if the widget is small or medium

        return Entry(date: date,
                     startDate: data.startDate,
                     seed: data.seed,
                     remainingTime: remainingTime,
                     quote: currentQuote,
                     isSmallWidget: isSmallWidget)
    }
    

    func fetchQuote() -> String {
        var currentQuote = ""

        var currentIndex = Quote.currentIndex
        currentIndex += 1

        if currentIndex >= Quote.regularQuotes.count {
            currentIndex = 0
        }

        UserDefaults.standard.setValue(currentIndex, forKey: "currentIndex")
        currentQuote = Quote.regularQuotes[currentIndex]

        if DataService().religion == "Muslim" {
            if Int.random(in: 0 ... 1) == 0 { // use regular quote or muslim quote
                var muslimIndex = UserDefaults.standard.integer(forKey: "muslimIndex")
                muslimIndex += 1
                if muslimIndex >= Quote.muslimQuotes.count {
                    muslimIndex = 0
                }

                UserDefaults.standard.setValue(muslimIndex, forKey: "muslimIndex")
                currentQuote = Quote.muslimQuotes[muslimIndex]
            }
        } else if DataService().religion == "Christian" {
            if Int.random(in: 0 ... 1) == 0 { // use regular quote or muslim quote
                var christianIndex = UserDefaults.standard.integer(forKey: "christianIndex")
                christianIndex += 1
                if christianIndex >= Quote.christianQuotes.count {
                    christianIndex = 0
                }

                UserDefaults.standard.setValue(christianIndex, forKey: "christianIndex")
                currentQuote = Quote.christianQuotes[christianIndex]
            }
        }
        return currentQuote
    }

    // timer timeline
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
//        let currentDate = Date()
//        var entries: [Entry] = []
//
//        // Create entries for the next 60 seconds (updating every second)
//        for offset in 0..<(1000) {
//            let entryDate = Calendar.current.date(byAdding: .second, value: offset, to: currentDate)!
//            entries.append(createEntry(for: entryDate))
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }

}
