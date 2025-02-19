// import SwiftUI
//
// struct EducationStory: View {
//    @ObservedObject var viewModel: EducationViewModel
//    @State private var progress: [CGFloat] = []
//    @State private var timer: Timer?
//    @State private var isComplete = false
//    @State private var userInput = ""
//    @FocusState private var isTextEditorFocused: Bool
//    @Environment(\.modelContext) private var modelContext
//    @EnvironmentObject var mainVM: MainViewModel
//    @EnvironmentObject var homeVM: HomeViewModel
//
//    var body: some View {
//        ZStack {
//            if viewModel.currentSlide == 0 {
//                Color.primaryPurple.edgesIgnoringSafeArea(.all).opacity(0.7)
//            } else {
//            Color.primaryBackground.edgesIgnoringSafeArea(.all).opacity(0.85)
//            }
//            GeometryReader { g in
//                VStack(alignment: .leading) {
//                    // Progress bars
//                    HStack {
//
//                    }
//                    .padding(.horizontal)
//                    if viewModel.currentSlide != viewModel.selectedLesson.slides.count {
//
//                    HStack(spacing: 4) {
//                        Image(systemName: "xmark")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 16)
//                            .foregroundColor(.white)
//                            .padding(.trailing)
//                            .onTapGesture {
//                                Analytics.shared.logActual(event: "EducationScreen: Tapped X", parameters: ["lesson":viewModel.selectedLesson.id, "slide": viewModel.currentSlide])
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                withAnimation {
//                                    viewModel.showEducation.toggle()
//                                }
//                            }
//
//                            ForEach(0..<viewModel.selectedLesson.slides.count + 1, id: \.self) { index in
//                                GeometryReader { geo in
//                                    ZStack(alignment: .leading) {
//                                        Rectangle()
//                                            .fill(Color.white.opacity(0.2))
//                                        Rectangle()
//                                            .fill(Color.white)
//                                            .frame(width: geo.size.width * (progress[safe: index] ?? 0))
//                                    }
//                                }
//                                .frame(height: 4)
//                            }
//                        }
//                    .padding(.horizontal)
//                    .padding(.top, 8)
//                    }
//
//
//
//                    if viewModel.currentSlide < viewModel.selectedLesson.slides.count {
//                        VStack(alignment: .leading) {
//                            if  viewModel.selectedLesson.slides[viewModel.currentSlide].type != "action" {
//                                Text(viewModel.selectedLesson.title)
//                                    .foregroundColor(Color.white)
//                                    .sfFont(weight: .bold, size: .h1)
//                                Text("Lesson \(abs(viewModel.selectedLesson.id))")
//                                    .foregroundColor(Color.primaryForeground)
//                                    .sfFont(weight: .medium, size: .h3p1)
//                            }
//
//                            if viewModel.currentSlide == 0 {
//                                HStack {
//                                    Spacer()
//                                    viewModel.selectedLesson.img
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 128)
//                                        .shadow(color: .black.opacity(0.5), radius: 24)
//                                        .padding(48)
//                                    Spacer()
//                                }
//                            }
//                            SlideView(slide: viewModel.selectedLesson.slides[viewModel.currentSlide], userInput: $userInput)
//                        }.padding()
//                    } else {
//                        VStack {
//                            LottieView(loopMode: .playOnce, animation: "checkmark", isVisible: .constant(true))
//                                .frame(width: 350)
//                            VStack(alignment: .center) {
//                                Text("Lesson Completed")
//                                    .foregroundColor(Color.white)
//                                    .sfFont(weight: .bold, size: .h1)
//                                    .multilineTextAlignment(.center)
//                                Text("Great work, you have completed this lesson.")
//                                    .foregroundColor(Color.primaryForeground)
//                                    .sfFont(weight: .medium, size: .h3p1)
//                                    .multilineTextAlignment(.center)
//                            }.offset(y: -100)
//
//                            Spacer()
//                            SharedComponents.PrimaryButton(title: "Complete") {
//                                Analytics.shared.logActual(event: "EducationScreen: Clicked Complete")
//                                mainVM.currUser.completedLessons.append(viewModel.selectedLesson.id)
//                                viewModel.completeLesson(viewModel.selectedLesson.id)
//                                viewModel.showEducation.toggle()
//                                viewModel.saveState()
//                                viewModel.currentSlide = 0
//
//                                DataManager.shared.saveContext(context: modelContext)
//
//                                if FirebaseService.isLoggedIn() {
//                                    Task {
//                                        do {
//                                            try await FirebaseService.shared.updateDocument(collection: "users", object: mainVM.currUser)
//                                        } catch {
//                                            print(error.localizedDescription)
//                                        }
//                                    }
//                                }
//
//                                if homeVM.currentScreen == .education {
//                                    homeVM.showCheckIn = true
//                                    homeVM.currentScreen = .nextSteps
//                                }
//                            }
//                        }
//                    }
//
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
//                                    if viewModel.selectedLesson.slides[viewModel.currentSlide].type == "action" &&  userInput.count < 5  {
//                                    } else {
//                                        nextSlide()
//                                    }
//                                }
//                            }
//                        }
//                )
//
//
//
//                // TextEditor layer
//                if viewModel.currentSlide < viewModel.selectedLesson.slides.count &&
//                   viewModel.selectedLesson.slides[viewModel.currentSlide].type == "action" {
//                    VStack {
//                        ZStack(alignment: .topTrailing) {
//                            TextEditor(text: $userInput)
//                                .frame(height: 200)
//                                .padding()
//                                .background(Color(.systemGray6))
//                                .cornerRadius(8)
//                                .sfFont(weight: .medium, size: .p2)
//
//                            // Character counter circle
//                            ZStack {
//                                Circle()
//                                    .fill(Color.primaryPurple)
//                                    .frame(width: 40, height: 40)
//                                Text("\(userInput.count)")
//                                    .sfFont(weight: .medium, size: .p3)
//                                    .foregroundColor(.white)
//                            }
//                            .offset(x: 8, y: -8)
//                        }
//                        .offset(y: 160)
//                        .padding(.horizontal, 28)
//                        Spacer()
//                        SharedComponents.PrimaryButton(title: "Done") {
//                            mainVM.currUser.userExercises["\(viewModel.selectedLesson.exercise)+\(Date().toString())"] = userInput
//                            DataManager.shared.saveContext(context: modelContext)
//                            viewModel.completeLesson(viewModel.selectedLesson.id)
//                            Task {
//                                do {
//                                    try await FirebaseService.shared.updateDocument(collection: "users", object: mainVM.currUser)
//                                } catch {
//                                    print(error.localizedDescription)
//                                }
//                            }
//                            viewModel.saveState()
//                            nextSlide()
//                        }.disabled(userInput.count < 8)
//                        .opacity(userInput.count < 8 ? 0.3 : 1)
//                        .padding()
//                    }.onAppear {
//                        // Set focus to TextEditor when it appears
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            self.isTextEditorFocused = true
//                        }
//                    }
//                }
//            }
//        }
//        .onAppear {
//            progress = Array(repeating: 0, count: viewModel.selectedLesson.slides.count + 1)
//            startLoading()
//        }
//    }
//
//    func startLoading() {
//
//        progress[viewModel.currentSlide] = 0
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
//            withAnimation {
//                if progress[viewModel.currentSlide] < 1 {
//                    progress[viewModel.currentSlide] += 0.01
//                } else {
//                    timer?.invalidate()
//                    isComplete = viewModel.currentSlide == viewModel.selectedLesson.slides.count - 1
//                }
//            }
//        }
//    }
//
//    func nextSlide() {
//        if viewModel.currentSlide < viewModel.selectedLesson.slides.count {
//            progress[viewModel.currentSlide] = 1
//            timer?.invalidate()
//            viewModel.currentSlide += 1
//            if viewModel.currentSlide == viewModel.selectedLesson.slides.count {
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
//        if viewModel.currentSlide > 0 {
//            progress[viewModel.currentSlide] = 0
//            viewModel.currentSlide -= 1
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
//                if slide.number != 1 && slide.type != "action" {
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
// extension Array {
//    subscript(safe index: Int) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
// }
//
// #Preview {
//    EducationStory(viewModel: EducationViewModel())
//        .environmentObject(MainViewModel())
// }
