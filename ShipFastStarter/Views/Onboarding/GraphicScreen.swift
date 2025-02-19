import SwiftUI

struct AnimatedChartView: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false

    var body: some View {
        ZStack {
            Image(.genderBg)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Quit porn forever in as little as 34 days.")
                    .overusedFont(weight: .semiBold, size: .h1)
                    .foregroundColor(.white)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: animateContent)

                Image(.graphic)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .padding(.vertical)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)
                if UIDevice.hasNotch {
                    VStack(alignment: .leading, spacing: 24) {
                        SharedComponents.CustomSubtitleText(title: "The key milestones are", color: .white)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                        ForEach(0 ..< 3) { index in
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .overusedFont(weight: .bold, size: .h2)
                                    .foregroundColor(index == 0 ? .orange : (index == 1 ? .green : .primaryBlue))
                                    .shadow(color: index == 0 ? Color.orange : (index == 1 ? Color.green : Color.primaryBlue), radius: 12)
                                SharedComponents.CustomSubtitleText(title: milestoneTexts[index], color: .white)
                            }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.3 + Double(index) * 0.1), value: animateContent)
                        }
                    }
                }

                SharedComponents.PrimaryButton(title: "Continue") {
                    Analytics.shared.log(event: "GraphicScreen: Tapped Continue")
                    mainVM.onboardingScreen = .commit
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)
                .padding(.top, 12)
                Spacer()
            }
            .padding()
        }
        .onAppearAnalytics(event: "GraphicScreen: Screenload")
        .onAppear {
            animateContent = true
        }
    }

    private let milestoneTexts = [
        "Reduced anxiety and depression symptoms by around 20-30%.",
        "Enhanced focus and cognitive performance, with improvements of 30-50%.",
        "Increased relationship satisfaction by around 15-20%.",
    ]
}

struct AnimatedChartView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedChartView()
    }
}
