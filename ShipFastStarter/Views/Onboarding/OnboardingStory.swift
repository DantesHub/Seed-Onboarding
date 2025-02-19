import SplineRuntime
import SwiftUI

struct OnboardingStory: View {
    @Binding var showStory: Bool
    @State private var progress: [CGFloat] = []
    @State private var timer: Timer?
    @State private var isComplete = false
    @State private var userInput = ""
    @EnvironmentObject var mainVM: MainViewModel
    @State var currentSlide = 0
    @State private var hoursThisYear = 0
    @State private var daysThisYear = 0
    @State var time = 1.5
    @State var index = -1
    var topics = ["Increase your Confidence", "Increase Focus/Clarity", "Increase Dopamine", "Increase Energy", "Help you build muscle faster", "and so much more."]
    @State private var isDetailViewActive = false

    var body: some View {
        NavigationStack {
            ZStack {
                //            Color.black.edgesIgnoringSafeArea(.all)
                Image(uiImage: UIImage(named: "gender_bg")!)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                GeometryReader { g in
                    let height = g.size.height
                    let width = g.size.width
                    Spacer()
                        .frame(height: 40)

                    VStack(alignment: .leading) {
                        // Progress bars
                        Spacer()
                            .frame(height: 40)
                        HStack(spacing: 4) {
                            ForEach(0 ..< 3, id: \.self) { _ in
                                GeometryReader { _ in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.2))
                                        Rectangle()
                                            .fill(Color.white)
//                                            .frame(width: geo.size.width * (progress[safe: index] ?? 0))
                                    }
                                }

                                .frame(height: 4)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)

                        // bad
                        if currentSlide == 0 {
                            VStackLayout(alignment: .center, spacing: 0) {
                                Spacer()
                                    .frame(height: 100)

                                VStack(spacing: 24) {
                                    SharedComponents.CustomBoldText(title: "Let’s get the bad news out of the way first...", color: .white)
                                        .frame(height: 60)
                                        .padding(.horizontal)

                                    SharedComponents.CustomMediumText(title: "If you keep going the way you’re going right now, you’ll spend", color: .white)
                                        .frame(height: 60)
                                        .padding(.horizontal)
                                }

                                VStack(spacing: -24) {
                                    SharedComponents.CustomStrokeText(title: "\(formatNumber(mainVM.currUser.minsSavedPerDay * 365))", color: [Color.red, Color(hex: "#8EAAFF")], strokeColor: Color(hex: "#00B7FF")).padding(0)

                                    SharedComponents.CustomMediumText(title: "minutes", color: .white)
                                        .padding(.top)
                                }
                                Spacer()
                                    .frame(height: 40)

                                SharedComponents.CustomMediumText(title: "watching porn this year.", color: .white)

                            }.offset(y: -24)
                                .frame(maxWidth: .infinity)
                                .safeAreaPadding()

                            Spacer()

                        } else if currentSlide == 1 {
                            VStackLayout(alignment: .center, spacing: 0) {
                                Spacer()
                                    .frame(height: 90)

                                VStack(spacing: 12) {
                                    SharedComponents.CustomBoldText(title: "Here's the good news.", color: .white)
                                        .frame(height: 60)
                                        .padding(.horizontal)

                                    SharedComponents.CustomMediumText(title: "Nafs can make sure that doesn't happen. That means you'll have an extra", color: .white)
                                        .frame(height: 100)
                                        .padding(.horizontal, 32)
                                }

                                VStack(spacing: -24) {
                                    SharedComponents.CustomStrokeText(title: "\(formatNumber(mainVM.currUser.minsSavedPerDay * 365))", color: [Color.green, Color(hex: "#8EAAFF")], strokeColor: Color(hex: "#00B7FF")).padding(0)
                                        .offset(y: -16)

                                    SharedComponents.CustomMediumText(title: "minutes", color: .white)
                                        .padding(.top)
                                }

                                Spacer()
                                    .frame(height: 40)

                                SharedComponents.CustomMediumText(title: "to work on yourself.", color: .white)

                            }.offset(y: -24)
                                .frame(maxWidth: .infinity)
                                .safeAreaPadding()
                                .opacity(currentSlide == 1 ? 1 : 0)

                            Spacer()

                        } else if currentSlide == 2 {
                            VStack {
                                VStack(alignment: .center, spacing: 8) {
                                    Text("How it works")
                                        .overusedFont(weight: .bold, size: .h1)
                                        .foregroundColor(Color(.primaryBlue))
                                    Text("The more you abstain, the more your seed grows and evolves")
                                        .overusedFont(weight: .medium, size: .h3p1)
                                        .foregroundColor(Color(.primaryForeground))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 24)
                                .padding(.top)
                                HStack(alignment: .top) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.secondaryBackground)
                                            .frame(width: 150, height: 200)

                                        VStack(spacing: -12) {
                                            SplineView(sceneFileURL: Bundle.main.url(forResource: "originalSeed", withExtension: "splineswift"))
                                                .frame(width: 125, height: 125)
                                                .ignoresSafeArea(.all)
                                                .background(.clear)
                                                //                        .shadow(color: .white, radius: 3)
                                                .padding()
                                                .offset(y: -16)
                                            Text("Day 0")
                                                .sfFont(weight: .semibold, size: .h3p1)
                                                .foregroundColor(Color(.primaryForeground))
                                                .opacity(0.7)
                                                .padding()
                                                .offset(y: -12)
                                        }
                                        .offset(y: -12)
                                    }
                                    .frame(width: 150, height: height * 0.15)
                                    .offset(x: -12)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.secondaryBackground)
                                            .frame(width: 150, height: 200)

                                        VStack {
                                            SplineView(sceneFileURL: Bundle.main.url(forResource: "blueOrb", withExtension: "splineswift"))
                                                .frame(width: 150, height: 150)
                                                .ignoresSafeArea(.all)
                                                //                        .shadow(color: .white, radius: 3)
                                                .padding()
                                                .offset(y: 28)
                                            Text("Day 3")
                                                .sfFont(weight: .semibold, size: .h3p1)
                                                .foregroundColor(Color(.primaryForeground))
                                                .opacity(0.7)

                                        }.offset(y: -36)
                                    }
                                    .frame(height: height * 0.15)
                                }
                                .frame(width: width * 0.9)
                                .padding(.top, 64)
                                .offset(x: 12)
                                Spacer()
                                HStack(spacing: 34) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.secondaryBackground)
                                            .frame(width: 150, height: 200)

                                        VStack(spacing: -12) {
                                            SplineView(sceneFileURL: Bundle.main.url(forResource: "aiSphere", withExtension: "splineswift"))
                                                .frame(width: 130, height: 130)
                                                .ignoresSafeArea(.all)
                                                //                        .shadow(color: .white, radius: 3)
                                                .padding()

                                            Text("Day 14")
                                                .sfFont(weight: .semibold, size: .h3p1)
                                                .foregroundColor(Color(.primaryForeground))
                                                .opacity(0.7)
                                                .offset(y: -12)
                                        }
                                        .offset(y: -16)
                                    }
                                    .frame(width: 150, height: height * 0.15)

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.secondaryBackground)
                                            .frame(width: 150, height: 200)
                                        VStack(spacing: -12) {
                                            SplineView(sceneFileURL: Bundle.main.url(forResource: "marbleDyson", withExtension: "splineswift"))
                                                .frame(width: 150, height: 150)
                                                .ignoresSafeArea(.all)
                                                .background(.clear)
                                                //                        .shadow(color: .white, radius: 3)
                                                .padding()
                                            Text("Day 89")
                                                .sfFont(weight: .semibold, size: .h3p1)
                                                .foregroundColor(Color(.primaryForeground))
                                                .opacity(0.7)
                                                .offset(y: -12)
                                        }
                                        .offset(y: -16)
                                    }
                                    .frame(width: 150, height: height * 0.15)
                                }
                                .frame(width: width * 0.9)
                                .padding(.bottom)
                                Spacer()
                            }
                            Spacer()
                        } else if currentSlide == 3 {
                            VStack {
                                VStack(alignment: .center) {
                                    Spacer()
                                    Text("Now, let's look at how\nNafs can help you\nwith all of this starting\ntoday")
                                        .foregroundColor(Color.white)
                                        .multilineTextAlignment(.center)
                                        .sfFont(weight: .medium, size: .h1)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .frame(maxWidth: .infinity)
                                Spacer()
                            }
                        }

                        SharedComponents.PrimaryButton(title: currentSlide == 2 ? "I’m ready" : "Continue", action: {
                            Analytics.shared.logActual(event: "OnboardingStory: Clicked Continue")
                            if currentSlide == 2 {
                                withAnimation {
                                    showStory = false
                                    UserDefaults.standard.setValue(true, forKey: Constants.completedOnboarding)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    withAnimation {
                                        mainVM.onboardingScreen = .pricing
                                    }
                                }

                            } else {
                                nextSlide()
                            }
                        }).padding(.leading, 20)
                            .padding(.trailing, 20)
                        Spacer()
                            .frame(height: 40)
                        //                    SharedComponents.PrimaryButton(title: currentSlide == 2 ? "I’m ready" : "Continue") {
                        //                        Analytics.shared.logActual(event: "OnboardingStory: Clicked Continue")
                        ////                        if currentSlide == 3  {
                        //                        if currentSlide == 2 {
                        //                            showStory.toggle()
                        //                            mainVM.onboardingScreen = .welcome
                        ////                            mainVM.onboardingScreen = .explainer
                        //                        } else {
                        //                            nextSlide()
                        //                        }
                        //                    }.padding()
                    }
                    .padding(.top)
                    .padding(.bottom)
                    .contentShape(Rectangle()) // Make the entire view tappable
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                if value.startLocation.x < g.size.width / 2 {
                                    withAnimation {
                                        prevSlide()
                                    }
                                } else {
                                    withAnimation {
                                        if currentSlide == 2 {
                                            isDetailViewActive = true
                                        } else {
                                            nextSlide()
                                        }
                                    }
                                }
                            }
                    )
                }
                Spacer()
                    .frame(height: 40)
            }
        }

        .onAppear {
//            mainVM.currUser.minsSavedPerDay = 50
            hoursThisYear = Int(mainVM.currUser.minsSavedPerDay * 365)
            progress = Array(repeating: 0, count: 4)
            startLoading()
        }
    }

    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }

    func startLoading() {
        if currentSlide != 4 {
            progress[currentSlide] = 0
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                withAnimation {
                    if progress[currentSlide] < 1 {
                        progress[currentSlide] += 0.01
                    } else {
                        timer?.invalidate()
                        isComplete = currentSlide == 4
                    }
                }
            }
        }
    }

    func nextSlide() {
        if currentSlide < 4 {
            progress[currentSlide] = 1
            timer?.invalidate()
            currentSlide += 1
            if currentSlide == 4 {
                isComplete = true
            } else {
                startLoading()
            }
        } else {
            isComplete = true
        }
    }

    func prevSlide() {
        timer?.invalidate()

        if currentSlide > 0 {
            progress[currentSlide] = 0
            currentSlide -= 1
            startLoading()
        }
    }

    struct SlideView: View {
        let slide: Lesson.SlideContent
        @Binding var userInput: String

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                if slide.number != 1 && slide.type != "action" {
                    Text(slide.emoji)
                        .sfFont(weight: .medium, size: .huge)
                        .padding(.vertical)
                }
                Text(slide.subtext1)
                    .foregroundColor(Color.white)
                    .sfFont(weight: .medium, size: .h3p1)

                if !slide.subtext2.isEmpty {
                    Text(slide.subtext2)
                        .foregroundColor(Color.white)
                        .sfFont(weight: .medium, size: .h3p1)
                        .padding(.top, 32)
                }
            }
        }
    }
}

// to avoid index out of range error

#Preview {
    OnboardingStory(showStory: .constant(true))
        .environmentObject(MainViewModel())
}

// struct OnboardingStory: View {
//    @Binding var showStory: Bool
//    @State private var progress: [CGFloat] = []
//    @State private var timer: Timer?
//    @State private var isComplete = false
//    @State private var userInput = ""
//    @EnvironmentObject var mainVM: MainViewModel
//    @State var currentSlide = 0
//    @State private var hoursThisYear = 0
//    @State private var daysThisYear = 0
//    @State var time = 1.5
//    @State var index = -1
//    var topics = ["Increase your Confidence", "Increase Focus/Clarity", "Increase Dopamine", "Increase Energy", "Help you build muscle faster", "and so much more."]
//
//    var body: some View {
//        ZStack {
//
//            Color.black.edgesIgnoringSafeArea(.all)
//
//            GeometryReader { g in
//                VStack(alignment: .leading) {
//                    // Progress bars
//                    HStack(spacing: 4) {
//                        ForEach(0..<4, id: \.self) { index in
//                            GeometryReader { geo in
//                                ZStack(alignment: .leading) {
//                                    Rectangle()
//                                        .fill(Color.white.opacity(0.2))
//                                    Rectangle()
//                                        .fill(Color.white)
//                                        .frame(width: geo.size.width * (progress[safe: index] ?? 0))
//                                }
//                            }
//                            .frame(height: 4)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 8)
//
//                    // bad
//                    if currentSlide == 0 {
//                        VStack(alignment: .center) {
//                            Spacer()
//                            Text("Some not-so\ngood news,\nand some great news.")
//                                .foregroundColor(Color.white)
//                                .multilineTextAlignment(.center)
//                                .sfFont(weight: .medium, size: .h1)
//                            Spacer()
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                    } else if currentSlide == 1 {
//                        Spacer()
//                        VStack(spacing: 24) {
//                            Spacer()
//                            Text("The bad news is that you'll spend")
//                                .foregroundColor(Color.white)
//                                .multilineTextAlignment(.center)
//                                .sfFont(weight: .semibold, size: .h1)
//                            Text("\(hoursThisYear) hours")
//                                .multilineTextAlignment(.center)
//                                .sfFont(weight: .bold, size: .titleHuge)
//                                .foregroundStyle(
//                                    LinearGradient(
//                                        colors: [.blue, .purple],
//                                        startPoint: .leading,
//                                        endPoint: .trailing
//                                    )
//                                )
//                            Text("watching porn this year.")
//                                .foregroundColor(Color.white)
//                                .multilineTextAlignment(.center)
//                                .sfFont(weight: .semibold, size: .h1)
//                            Spacer()
//                        }
//                        .offset(y: -24)
//                        .frame(maxWidth: .infinity)
//                        .sfFont(weight: .medium, size: .h1)
//                        Spacer()
//                    } else if currentSlide == 2 {
//                        Spacer()
//                        VStack(alignment: .leading, spacing: 24) {
//                            (Text("The good news is that ")
//                                .foregroundColor(Color.primaryForeground)
//                             + Text("Nafs ")
//                                .foregroundColor(Color.secondaryPurple)
//                             + Text("can help you")
//                                .foregroundColor(Color.primaryForeground))
//                                .sfFont(weight: .semibold, size: .h1)
//                            if index >= 0 {
//                                ForEach(0...index, id: \.self) { idx in
//                                    HStack(alignment: .center, spacing: 12) {
//                                        Image(systemName: "checkmark.circle.fill")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 24)
//                                            .foregroundColor(.primaryPurple)
//                                        Text(topics[idx])
//                                            .foregroundColor(Color.white)
//                                            .sfFont(weight: .semibold, size: .h2)
//                                    }
//                                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                                              .animation(.easeOut(duration: 0.5), value: index)
//                                }
//                            }
//                            Spacer()
//                        }
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .sfFont(weight: .medium, size: .h1)
//                        .onAppear {
//                            if index != 5 {
//                                timer = Timer.scheduledTimer(withTimeInterval: time / 2, repeats: true) { _ in
//                                       withAnimation(.easeIn) {
//                                           index += 1
//                                           if index == 5 {
//                                               timer?.invalidate()
//                                           }
//                                       }
//                                   }
//                            }
//                        }
//                        Spacer()
//                    } else if currentSlide == 3 {
//                        VStack {
//                            VStack(alignment: .center) {
//                                Spacer()
//                                Text("Now, let's look at how\nNafs can help you\nwith all of this starting\ntoday")
//                                    .foregroundColor(Color.white)
//                                    .multilineTextAlignment(.center)
//                                    .sfFont(weight: .medium, size: .h1)
//                                Spacer()
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            Spacer()
//                        }
//                    }
//
//                    SharedComponents.PrimaryButton(title: "Continue") {
//                        Analytics.shared.logActual(event: "OnboardingStory: Clicked Continue")
//                        if currentSlide == 3  {
//                            showStory.toggle()
//                            mainVM.onboardingScreen = .explainer
//                        } else {
//                            nextSlide()
//                        }
//                    }
//                    Spacer()
//                }
//                .padding()
//                .contentShape(Rectangle()) // Make the entire view tappable
//                .gesture(
//                    DragGesture(minimumDistance: 0)
//                        .onEnded { value in
//                            if value.startLocation.x < g.size.width / 2 {
//                                withAnimation {
//                                    prevSlide()
//                                }
//                            } else {
//                                withAnimation {
//                                    if currentSlide == 3  {
//                                        showStory.toggle()
//                                        mainVM.onboardingScreen = .explainer
//                                    } else {
//                                        nextSlide()
//                                    }
//                                }
//                            }
//                        }
//                )
//            }
//        }
//        .onAppear {
//            mainVM.currUser.minsSavedPerDay = 50
//            hoursThisYear = Int((mainVM.currUser.minsSavedPerDay * 365) / 60)
//            progress = Array(repeating: 0, count: 4)
//            startLoading()
//
//
//        }
//    }
//
//    func startLoading() {
//        if currentSlide != 4 {
//            progress[currentSlide] = 0
//            timer?.invalidate()
//            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
//                withAnimation {
//                    if progress[currentSlide] < 1 {
//                        progress[currentSlide] += 0.01
//                    } else {
//                        timer?.invalidate()
//                        isComplete = currentSlide == 4
//                    }
//                }
//            }
//        }
//    }
//
//    func nextSlide() {
//        if currentSlide < 4 {
//            progress[currentSlide] = 1
//            timer?.invalidate()
//            currentSlide += 1
//            if currentSlide == 4 {
//                isComplete = true
//            } else {
//                startLoading()
//            }
//        } else {
//            isComplete = true
//        }
//    }
//
//    func prevSlide() {
//        timer?.invalidate()
//
//        if currentSlide > 0 {
//            progress[currentSlide] = 0
//            currentSlide -= 1
//            startLoading()
//        }
//    }
//
//    struct SlideView: View {
//        let slide: Lesson.SlideContent
//        @Binding var userInput: String
//
//        var body: some View {
//            VStack(alignment: .leading, spacing: 10) {
//                if slide.number != 1 && slide.type != "action"{
//                    Text(slide.emoji)
//                        .sfFont(weight: .medium, size: .huge)
//                        .padding(.vertical)
//
//                }
//                Text(slide.subtext1)
//                    .foregroundColor(Color.white)
//                    .sfFont(weight: .medium, size: .h3p1)
//
//                if !slide.subtext2.isEmpty {
//                    Text(slide.subtext2)
//                        .foregroundColor(Color.white)
//                        .sfFont(weight: .medium, size: .h3p1)
//                        .padding(.top, 32)
//                }
//
//
//            }
//        }
//    }
//
// }
//
//
//// to avoid index out of range error
//
//
// #Preview {
//    OnboardingStory(showStory: .constant(true))
//        .environmentObject(MainViewModel())
// }
