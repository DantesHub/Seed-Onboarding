import SwiftUI
import WidgetKit

struct widgetEntryView: View {
    var entry: Provider.Entry
    @State var streak = 0
    @State private var progress = 0.3
    @State var currentQuote = ""
    @State private var timeUnit = ""
    @State private var isPro = false

    var body: some View {
        ZStack {
                ZStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.quote)
                                .overusedFont(weight: .medium, size: .p3)
                                .foregroundColor(.white)
                                .frame(height: 60, alignment: .bottom)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .lineLimit(3)
                                .minimumScaleFactor(0.85)
                                .allowsTightening(true)
                                .offset(y: 2)
                            HStack(alignment: .center) {
                                VStack(alignment: .center, spacing: -2) {
                                    if self.streak < 10 {
                                        Text("\(self.streak)")
                                            .overusedFont(weight: .bold, size: .title)
                                            .foregroundColor(.white)
                                        Text("\(timeUnit)")
                                            .sfFont(weight: .medium, size: .p4)
                                            .foregroundColor(.white)
                                            .opacity(0.6)
                                            .offset(x: 4, y: -4)
                                    } else {
                                        Text("\(self.streak)")
                                            .overusedFont(weight: .bold, size: .h1Big)
                                            .foregroundColor(.white)
                                        Text("\(timeUnit)")
                                            .sfFont(weight: .medium, size: .p4)
                                            .foregroundColor(.white)
                                            .opacity(0.6)
                                            .offset(x: 0, y: -4)
                                    }
                               
                                  
                                }
                                Spacer()
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 12)
                                        .foregroundColor(Color.white.opacity(0.3))
                                        .frame(width: 44, height: 44)

                                    Circle()
                                        .trim(from: 0.0, to: CGFloat(progress))
                                        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                        .foregroundColor(.blue)
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 42, height: 42)

                                    Image(entry.seed)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom)
                        }

//                        Link(destination: URL(string: "nafs://gopro")!) {
//                            VStack(spacing: 12) {
//                                Text("Widget is only available for pro users")
//                                    .overusedFont(weight: .medium, size: .p3)
//                                    .foregroundColor(.white)
//                                    .frame(height: 60, alignment: .bottom)
//                                    .padding(.horizontal, 20)
//                                    .padding(.top, 8)
//                                    .lineLimit(3)
//                                    .minimumScaleFactor(0.85)
//                                    .allowsTightening(true)
//                                
//                                HStack {
//                                    Image(systemName: "lock.fill")
//                                        .scaledToFit()
//                                        .foregroundColor(.white)
//                                    Text("Go Pro \(isPro)")
//                                        .foregroundColor(.white)
//                                        .overusedFont(weight: .medium, size: .p3)
//                                }
//                                .frame(width: 130, height: 40)
//                                .background(
//                                    LinearGradient(
//                                        stops: [
//                                            Gradient.Stop(color: Color(red: 0.44, green: 0.45, blue: 1), location: 0.00),
//                                            Gradient.Stop(color: Color(red: 0.1, green: 0.13, blue: 0.81), location: 1.00),
//                                        ],
//                                        startPoint: UnitPoint(x: 0.49, y: 0.04),
//                                        endPoint: UnitPoint(x: 0.5, y: 1.25)
//                                    )
//                                )
//                                .cornerRadius(16)
//                            }
//                        }
                    
                }
//                .contentTransition(.identity)
//                .transaction { transaction in
//                    transaction.animation = nil
//                    transaction.disablesAnimations = true
//                }
//                .containerBackground(for: .widget) {
//                    Color.clear
//                }
                .padding(4)
        }
        .containerBackground(for: .widget) {
            Image(.widgetBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .onAppear {
            if let date = Date.fromString(entry.startDate) {
                let elapsed = Date().timeIntervalSince(date)
                let numHours = Int(elapsed / 3600)
                if numHours < 24 {
                    self.streak = numHours
                    self.timeUnit = "hour\(numHours == 1 ? "" : "s")"
                } else {
                    let numDays = Int(elapsed / 86400)
                    self.streak = numDays
                    self.timeUnit = "day\(numDays == 1 ? "" : "s")"
                }
                self.progress = Orb.calculateProgress(startDate: date)
            }
            
             isPro = DataService().isPro
        }
    }
}

// Ensure the preview is set up correctly
struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Seed")
        .description("stay locked in")
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    widget() 
} timeline: {
    SimpleEntry(
        date: .now,
        startDate: "2023-01-01",
        seed: "moon",
        remainingTime: 86400,
        quote: "Every action you take is a vote for your future self",
        isSmallWidget: false
    )
}
