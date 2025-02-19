import SwiftUI

struct Tabbar: View {
    @ObservedObject var mainVM: MainViewModel

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
//                Rectangle()
//                    .fill(Color.black.opacity(0.4))
//                    .frame(height: 1)
//                    .padding(.horizontal, -10)
                HStack(spacing: -4) {
                    TabBarItem(title: "clock", imageName: "clock", isSelected: mainVM.currentPage == .home)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                mainVM.currentPage = .home
                                Analytics.shared.log(event: "Tabbar: Tapped Home")
                            }
                        }
                    Spacer()
                    TabBarItem(title: "Notes", imageName: mainVM.currentPage == .course ? "book.closed.fill" : "book.closed", isSelected: mainVM.currentPage == .course)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                mainVM.currentPage = .course
                                Analytics.shared.log(event: "Tabbar: Tapped Notes")
                            }
                        }
                    Spacer()
                    TabBarItem(title: "Stats", imageName: "chart.bar", isSelected: mainVM.currentPage == .stats)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                mainVM.currentPage = .stats
                                Analytics.shared.log(event: "Tabbar: Tapped Stats")
                            }
                        }
                    Spacer()
                    TabBarItem(title: "Profile", imageName: "person", isSelected: mainVM.currentPage == .profile)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                mainVM.currentPage = .profile
                                Analytics.shared.log(event: "Tabbar: Tapped History")
                            }
                        }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
//                .padding(.top, 12)
//                .offset(y: -12)
                Spacer()
            }
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                .background(.clear)
                .edgesIgnoringSafeArea(.bottom)
        }
        .cornerRadius(32)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            LinearGradient(
                colors: [mainVM.currentPage != .home ? Color(hex: "#03041E") : Color(red: 0.02, green: 0.02, blue: 0.04), Color(red: 0.04, green: 0.04, blue: 0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).opacity(mainVM.currentPage != .home ? 1 : 0)
                .cornerRadius(30)
        )
    }
}

#Preview {
    Tabbar(mainVM: MainViewModel())
}

struct TabBarItem: View {
    let title: String
    let imageName: String
    let isSelected: Bool
//    let action: () -> Void

    var body: some View {
        ZStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(isSelected ? .primaryBlue : .gray)
        }.frame(width: 88, height: 64)
            .background(Color(hex: "#03041E"))

        //            Text(title)
        //                .sfFont(weight: .medium, size: .p3)
        //                .foregroundColor(isSelected ? .primaryPurple : .gray)

//            .onTapGesture {
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                withAnimation {
//                    action()
//                }
//            }
    }
}
