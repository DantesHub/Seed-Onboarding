//
//  PanicButton.swift
//  Resolved
//
//  Created by Dante Kim on 8/13/24.
//

import SwiftData
import SwiftUI

enum PanicPage {
    case breathwork
    case tasks
    case chat
    case notes
    case home
    case dhikr
}

struct PanicButtonScreen: View {
    @StateObject private var store = ManagedSettingsStore()
    @State private var showActivityPicker = false
//    @StateObject private var manager = ShieldViewModel()

    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var breathVM: BreathworkViewModel
    @EnvironmentObject var dhikrVM: DhikrViewModel
    var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 2)
    @State var page: PanicPage = .home
    @State var reasons = ["20 pushups right now", "20 situps right now.", "20 squats right now.", "Take a cold shower.", "Listen to your lock-in song.", "Waking up tomorrow is gonna be exhausting.", "Visualize your future self.", "Think about someone you look up to."]
    @State var motivationalNotes: [String: String] = [:]
    @Query private var sessionHistory: [SoberInterval]

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            GeometryReader { g in
                let width = g.size.width
                let height = g.size.height
                VStack(alignment: .leading) {
                    if page != .dhikr {
                        HStack {
                            Image(systemName: page == .home ? "xmark.circle.fill" : "arrow.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    withAnimation {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        if page == .home {
                                            mainVM.tappedPanic = false
                                        } else {
                                            page = .home
                                        }
                                    }
                                }
                                .foregroundColor(Color.primaryForeground)
                            Spacer()
                            if !chatVM.messages.filter({ $0.role != "system" }).isEmpty && page == .chat {
                                Text("Prompts")
                                    .foregroundColor(.primaryPurple)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            chatVM.showPrompts = true
                                        }
                                    }
                            }
                        }.padding(.horizontal, 32)
                    }

                    if page == .home {
                        VStack {
                            Image(systemName: "exclamationmark.shield.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48)
                                .foregroundColor(.red)
                            Text("PAUSE.")
                                .sfFont(weight: .bold, size: .h1)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                            Text("Every action has a consequence.")
                                .sfFont(weight: .medium, size: .h3p1)
                                .foregroundColor(Color.primaryForeground)
                                .multilineTextAlignment(.center)
                        }.frame(maxWidth: .infinity)
                        List {
                            HStack {
                                Image(systemName: "message.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24)
                                    .padding(.trailing)

                                Text("Chat with your coach")
                                    .sfFont(weight: .medium, size: .h3p1)
                                Spacer()
                                // Reduced size to match the image
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.primaryForeground)
                            }
                            .padding(.horizontal, 16) // Add horizontal padding inside the HStack
                            .frame(height: 48) // Reduce height to match the image
                            .background(Color.secondaryBackground)
                            .cornerRadius(12) // Apply corner radius to the background
                            .foregroundColor(.primaryForeground)
                            .onTapGesture {
                                Analytics.shared.log(event: "PanicButton: Tapped Chat")
                                withAnimation(.easeOut(duration: 1)) {
                                    page = .chat
                                }
                            }
//                            ShieldView()
//                            NavigationStack {
//                            ShieldView()
////                            }
//                                .environmentObject(manager)
//                                .task(id: "requestAuthorizationTaskID") {
//                                    await manager.requestAuthorization()
//                                }
//                            HStack {
//                                Image(systemName: "globe.europe.africa.fill")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 24)
//                                    .padding(.trailing)
//
//                                Text("Block sites and apps")
//                                    .sfFont(weight: .medium, size: .h3p1)
//                                Spacer()
//                                // Reduced size to match the image
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(Color.primaryForeground)
//                            }
//                            .padding(.horizontal, 16)  // Add horizontal padding inside the HStack
//                            .frame(height: 48)  // Reduce height to match the image
//                            .background(Color.secondaryBackground)
//                            .cornerRadius(12)  // Apply corner radius to the background
//                            .foregroundColor(.primaryForeground)
//                            .onTapGesture {
//
                            ////                                if let url = URL(string: "App-Prefs:root=SAFARI&path=ContentBlockers") {
                            ////                                                    UIApplication.shared.open(url)
                            ////                                                }
//                            }
                            if mainVM.currUser.religion != "Muslim" {
                                HStack {
                                    Image(systemName: "hands.and.sparkles.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24) // Reduced size to match the image
                                        .padding(.trailing)
                                    Text("Dhikr")
                                        .sfFont(weight: .medium, size: .h3p1)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.primaryForeground)
                                }
                                .padding(.horizontal, 16) // Add horizontal padding inside the HStack
                                .frame(height: 48) // Reduce height to match the image
                                .background(Color.secondaryBackground)
                                .cornerRadius(12) // Apply corner radius to the background
                                .foregroundColor(.primaryForeground)
                                .onTapGesture {
                                    Analytics.shared.log(event: "PanicButton: Tapped Breathwork")
                                    withAnimation {
                                        page = .dhikr
                                    }
                                }
                            }
                            HStack {
                                Image(systemName: "wind")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24) // Reduced size to match the image
                                    .padding(.trailing)
                                Text("Breathwork")
                                    .sfFont(weight: .medium, size: .h3p1)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.primaryForeground)
                            }
                            .padding(.horizontal, 16) // Add horizontal padding inside the HStack
                            .frame(height: 48) // Reduce height to match the image
                            .background(Color.secondaryBackground)
                            .cornerRadius(12) // Apply corner radius to the background
                            .foregroundColor(.primaryForeground)
                            .onTapGesture {
                                Analytics.shared.log(event: "PanicButton: Tapped Breathwork")
                                withAnimation {
                                    page = .breathwork
                                }
                            }
                            HStack {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20) // Reduced size to match the image
                                    .padding(.trailing)
                                Text("Emergency Tasks")
                                    .sfFont(weight: .medium, size: .h3p1)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.primaryForeground)
                            }
                            .padding(.horizontal, 16) // Add horizontal padding inside the HStack
                            .frame(height: 48) // Reduce height to match the image
                            .background(Color.secondaryBackground)
                            .cornerRadius(12) // Apply corner radius to the background
                            .foregroundColor(.primaryForeground)
                            .onTapGesture {
                                Analytics.shared.log(event: "PanicButton: Tapped Breathwork")
                                withAnimation {
                                    page = .tasks
                                }
                            }
                            HStack {
                                Image(systemName: "note.text")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20) // Reduced size to match the image
                                    .padding(.trailing)
                                Text("Notes to yourself")
                                    .sfFont(weight: .medium, size: .h3p1)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.primaryForeground)
                            }
                            .padding(.horizontal, 16) // Add horizontal padding inside the HStack
                            .frame(height: 48) // Reduce height to match the image
                            .background(Color.secondaryBackground)
                            .cornerRadius(12) // Apply corner radius to the background
                            .foregroundColor(.primaryForeground)
                            .onTapGesture {
                                Analytics.shared.log(event: "PanicButton: Tapped Breathwork")
                                withAnimation {
                                    page = .notes
                                }
                            }
                        }
                        .scrollDisabled(true)
                        .onAppear {
                            UITableView.appearance().showsVerticalScrollIndicator = false
                        }
                        .colorScheme(.dark)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
                        (Text("48 ")
                            .bold()
                            .foregroundColor(.primaryPurple)
                            +
                            Text("other users are panicking right now.")
                            .foregroundColor(.primaryForeground)
                        )
                        .sfFont(weight: .medium, size: .h2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primaryForeground)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 48)
                        Text("How strong are you?")
                            .sfFont(weight: .semibold, size: .h2)
                            .foregroundColor(.primaryPurple)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 48)
                            .padding(.bottom, 72)
                            .padding(.top, 8)
                    } else if page == .dhikr {
                        Dhikar(viewModel: dhikrVM, page: $page)
                            .environmentObject(mainVM)
                    } else if page == .breathwork {
                        BreathSelect
                    } else if page == .tasks {
                        List {
                            ForEach(reasons, id: \.self) { reason in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28)
                                        .foregroundColor(Color.primaryPurple)
                                        .padding(.trailing)
                                    Text(reason)
                                        .sfFont(weight: .medium, size: .h3p1)
                                        .foregroundColor(Color.primaryForeground)

                                }.padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                        }
                        .colorScheme(.dark)
                        .scrollIndicators(.hidden)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .identity))
                    } else if page == .notes {
                        List {
                            if mainVM.currUser.userExercises.isEmpty && motivationalNotes.isEmpty {
                                Text("No notes yet!")
                                    .foregroundColor(.primaryForeground)
                            } else {
                                if !mainVM.currUser.userExercises.isEmpty {
                                    ForEach(Array(mainVM.currUser.userExercises.keys.sorted()), id: \.self) { key in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Image(systemName: "note.text")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 24)
                                                        .foregroundColor(Color.primaryPurple)
                                                        .padding(.trailing, 4)
                                                    Text(mainVM.currUser.userExercises[key] ?? "")
                                                        .sfFont(weight: .medium, size: .p2)
                                                        .foregroundColor(Color.primaryForeground)
                                                }

                                                Text(key)
                                                    .sfFont(weight: .regular, size: .p3)
                                                    .foregroundColor(Color.primaryForeground)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                    }
                                }
                                ForEach(Array(motivationalNotes.enumerated()), id: \.element.key) { _, element in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Image(systemName: "note.text")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 24)
                                                    .foregroundColor(Color.primaryPurple)
                                                    .padding(.trailing)
                                                Text(element.value)
                                                    .sfFont(weight: .medium, size: .p2)
                                                    .foregroundColor(Color.primaryForeground)
                                            }

                                            Text(element.key)
                                                .sfFont(weight: .regular, size: .p3)
                                                .foregroundColor(Color.primaryForeground)
                                        }

                                    }.padding(.horizontal)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        .colorScheme(.dark)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .identity))
                        .scrollIndicators(.hidden)

                    } else {
                        ChatScreen(viewModel: chatVM)
                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .identity))
                            .environmentObject(mainVM)
                    }
                }
            }
        }

        .onAppear {
            for session in sessionHistory {
                motivationalNotes.merge(session.motivationalNotes) { _, new in new }
            }
        }
    }

    var BreathSelect: some View {
        ScrollView(showsIndicators: false) {
            Text("Breathwork")
                .sfFont(weight: .semibold, size: .h2)
                .foregroundColor(Color.primaryForeground)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: gridItemLayout, content: {
                ForEach(Breathwork.breathworks, id: \.self) { item in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            breathVM.selectedBreath = item
                            breathVM.showMiddle = true
                        }
                    } label: {
                        HomeSquare(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.75, breathwork: item)
                            .padding(.vertical, 8)
                    }
                }
            })
        }
        .padding(.horizontal)
    }
}

import ManagedSettings
import SafariServices
import SwiftUI

struct HomeSquare: View {
    @State private var isSmaller = false
    let width, height: CGFloat
    let breathwork: Breathwork

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.secondaryBackground)
                .border(Color.secondaryBackground)
                .cornerRadius(16)
                .frame(width: width * 0.42, height: height * (UIDevice.hasNotch ? 0.225 : 0.25), alignment: .center)
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: -2) {
                    Text(breathwork.title)
                        .frame(width: width * 0.225, alignment: .leading)
                        .sfFont(weight: .semibold, size: .h3p1)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.primaryForeground)
                        .minimumScaleFactor(0.05)
                        .lineLimit(3)
                        .padding(.top)
                    HStack(spacing: 4) {
                        Image(systemName: "wind")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10)
                        Text("Breathwork")
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.05)
                    }
                    .padding(.top, 10)
                    .foregroundColor(Color.gray)
                    HStack(spacing: 4) {
                        Image(systemName: breathwork.color.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10)
                        Text(breathwork.color.name.capitalized)
                            .padding(.leading, 2)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.05)
                    }
                    .padding(.top, 5)
                    .foregroundColor(Color.gray)
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10)
                        Text("Visual")
                            .padding(.leading, 2)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.05)
                    }
                    .padding(.top, 5)
                    .foregroundColor(Color.gray)
                    Spacer()
                }.padding(.leading, isSmaller ? 15 : 20)
                    .frame(width: width * 0.25, height: height * (UIDevice.hasNotch ? 0.18 : 0.2), alignment: .top)

                breathwork.img
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width * (isSmaller ? 0.14 : 0.15), height: height * 0.14, alignment: .center)
                    .padding(.leading, -16)
                    .padding(.top, isSmaller ? 30 : 20)

            }.offset(x: -4)
            if breathwork.isNew {
                Capsule()
                    .fill(Color.red)
                    .frame(width: 45, height: 20)
                    .overlay(
                        Text("New")
                            .sfFont(weight: .semibold, size: .p4)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.05)
                    )
                    .position(x: width * 0.38, y: 17)
                    .opacity(0.8)
            }
        }
    }
}

struct HomeSquare_Previews: PreviewProvider {
    static var previews: some View {
        HomeSquare(width: 425, height: 800, breathwork: Breathwork.breathworks[0])
    }
}
