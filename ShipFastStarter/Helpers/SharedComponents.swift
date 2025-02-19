import SwiftUI

enum SharedComponents {
    struct OnboardingButton: View {
        let title: String
        let font: Font
        let buttonAction: () -> Void
        @State private var selected = false

        var body: some View {
            Button(action: {
                withAnimation {
                    buttonAction()
                    selected.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        selected.toggle()
                    }
                }
            }) {
                Text(title)
                    .overusedFont(weight: .medium, size: .h3p1)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        SharedComponents.Gradients.primary
                            .clipShape(Capsule())
                            .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
            }
            .animation(.easeInOut(duration: 0.5), value: title)
            .padding(.horizontal, 40)
        }
    }

    enum Gradients {
        static let primary = LinearGradient(
            colors: [Color(red: 0.44, green: 0.45, blue: 1), Color(red: 0.1, green: 0.13, blue: 0.81)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
