import SwiftUI

struct TripAnimation: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1

    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ForEach(0 ..< 15) { index in
                    SwirlingPetal(petals: 8 + index * 2)
                        .stroke(
                            LinearGradient(gradient: Gradient(colors: [.purple, .blue, .pink]),
                                           startPoint: .leading,
                                           endPoint: .trailing),
                            lineWidth: 3
                        )
                        .rotationEffect(.degrees(rotation * Double(index + 1)))
                        .scaleEffect(scale)
                        .opacity(0.7)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onReceive(timer) { _ in
                withAnimation(.linear(duration: 0.02)) {
                    rotation += 0.5
                    scale = 1 + sin(rotation / 10) * 0.2
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SwirlingPetal: Shape {
    var petals: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0 ..< petals {
            let angle = 2 * .pi / CGFloat(petals) * CGFloat(i)
            let xOffset = radius * cos(angle)
            let yOffset = radius * sin(angle)

            let petalTip = CGPoint(x: center.x + xOffset, y: center.y + yOffset)
            let controlPoint1 = CGPoint(x: center.x + xOffset * 0.5, y: center.y + yOffset * 0.5)
            let controlPoint2 = CGPoint(x: center.x + xOffset * 0.9, y: center.y + yOffset * 0.9)

            path.move(to: center)
            path.addQuadCurve(to: petalTip, control: controlPoint1)
            path.addQuadCurve(to: center, control: controlPoint2)
        }

        return path
    }
}

struct ContentView: View {
    var body: some View {
        TripAnimation()
    }
}

#Preview {
    TripAnimation()
}
