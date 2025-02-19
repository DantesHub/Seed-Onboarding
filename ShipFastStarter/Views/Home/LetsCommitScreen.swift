//
//  LetsCommitScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 21/10/24.
//

import SuperwallKit
import SwiftUI
import PencilKit


struct LetsCommitScreen: View {
    var proFeatures: [String] = [
        "Prioritizing my mental and physical",
        "Staying focused and productive",
        "Letting go of my past self",
        "Becoming the person I want to be",
    ]
    @State private var isStamped = false
    @State private var hasStartedDrawing = false
    @State private var dragOffset: CGSize = .zero

    @State private var animateContent = false
    @State private var visibleFinger = false
    @EnvironmentObject var mainVM: MainViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                    .frame(height: 20)
                
                HStack {
                    SharedComponents.CustomBoldHeading(title: "Let's commit.", color: .white)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5), value: animateContent)
                    Spacer()
                }.padding()
                
                HStack {
                    SharedComponents.CustomSubtitleText(title: "From this day onwards, I commit to", color: .white)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)
                    Spacer()
                }.padding(.leading)
                VStack(alignment: .leading) {
                    ForEach(proFeatures.indices, id: \.self) { idx in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32)
                                .foregroundColor(.blue)
                            SharedComponents.CustomSubtitleText(title: proFeatures[idx], color: .white)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.2 + Double(idx) * 0.1), value: animateContent)
                    }
                }.padding(.leading, 8)
                ZStack {
                    SignatureView(hasStartedDrawing: $hasStartedDrawing)
                        .colorScheme(.light)
                    if visibleFinger && !hasStartedDrawing {
                        LottieView(loopMode: .playOnce, animation: "sign", isVisible: .constant(true))
                            .frame(height: 120)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        self.dragOffset = gesture.translation
                                        if abs(self.dragOffset.width) > 10 || abs(self.dragOffset.height) > 10 {
                                            self.hasStartedDrawing = true
                                            self.visibleFinger = false
                                        }
                                    }
                            )
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)

                HStack {
                    VStack {
                        SharedComponents.CustomVerySmallMediumText(title: "Your signature is not recorded", color: .white.opacity(0.5))
                        Spacer()
                    }

                    Spacer()
                    Image(.stamp)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.trailing)
                        .offset(x: -65, y: -110)
                        .scaleEffect(isStamped ? 1.0 : 3.0)
                        .opacity(isStamped ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 1.0), value: isStamped)
                }.padding(.leading)
                    .padding(.top, 0)
                Spacer()

                SharedComponents.OnboardingButton(title: "I commit to myself", font: FontManager.overUsedGrotesk(type: .medium, size: .h3p1)) {
                    isStamped = true
                    DataManager.shared.saveContext(context: modelContext)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        mainVM.onboardingScreen = .notification
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.7), value: animateContent)
                .padding(.bottom, 70)
                .disabled(!hasStartedDrawing)
                .opacity(hasStartedDrawing ? 1 : 0.25)

                Spacer()
                    .frame(height: 40)

            }.safeAreaPadding()
                .onAppear {
                    animateContent = true // Trigger animations when view appears
                    visibleFinger = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        if !hasStartedDrawing {
                            visibleFinger = false
                        }
                    }
                }

        }.navigationBarBackButtonHidden()
            .onAppearAnalytics(event: "CommitScreen: Screenload")
    }
}

#Preview {
    LetsCommitScreen()
}

struct SignatureView: View {
    @State private var canvasView = PKCanvasView()
    @State private var signatureImage: UIImage?
    @State private var isCanvasEmpty = true
    @Binding var hasStartedDrawing: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                PKCanvasRepresentation(canvasView: $canvasView, isCanvasEmpty: $isCanvasEmpty, hasStartedDrawing: $hasStartedDrawing)
                    .frame(height: 160)
                    .background(Color(hex: "070921"))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "212786"), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "00B7FF").opacity(0.25), radius: 10, x: 0, y: 4)
                    .onChange(of: hasStartedDrawing) { newValue in
                        if newValue {
                            SignatureManager.shared.saveSignature(canvasView.drawing)
                        }
                    }

                // Placeholder text
                if isCanvasEmpty {
                    SharedComponents.CustomSmallMediumText(title: "Sign your name using finger", color: Color(hex: "070921"))
                        .padding([.top, .leading], 16)
                }
            }
            .padding()
            .overlay(
                Group {
                    if !isCanvasEmpty {
                        Button(action: {
                            clearCanvas()
                            hasStartedDrawing = false
                            SignatureManager.shared.clearSignature()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .padding()
                        }
                        .offset(x: -24, y: 16)
                    }
                },
                alignment: .topTrailing
            )
        }
    }

    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
        isCanvasEmpty = true
    }
}


class SignatureManager {
    static let shared = SignatureManager()
    private let signatureKey = "userSignature"
    
    func saveSignature(_ drawing: PKDrawing) {
        if let data = try? JSONEncoder().encode(drawing) {
            UserDefaults.standard.set(data, forKey: signatureKey)
        }
    }
    
    func loadSignature() -> PKDrawing? {
        guard let data = UserDefaults.standard.data(forKey: signatureKey),
              let drawing = try? JSONDecoder().decode(PKDrawing.self, from: data) else {
            return nil
        }
        return drawing
    }
    
    func clearSignature() {
        UserDefaults.standard.removeObject(forKey: signatureKey)
    }
}

// struct CustomStampView: View {
//    var body: some View {
//        ZStack {
//            // Starburst border effect
//            Circle()
//                .strokeBorder(Color.orange, lineWidth: 8)
//                .background(Circle().fill(Color.orange.opacity(0.5)))
//                .frame(width: 50, height: 50)
//                .overlay(
//                    // Starburst effect around the circle
//                    ForEach(0..<30) { i in
//                        Rectangle()
//                            .fill(Color.orange.opacity(0.9))
//                            .frame(width: 10, height: 25)
//                            .offset(y: -125)
//                            .rotationEffect(.degrees(Double(i) * 12))
//                    }
//                )
//                .shadow(radius: 5)
//
//            // Inner circle
//            Circle()
//                .fill(Color.orange.opacity(0.3))
//                .frame(width: 50, height: 220)
//
//            // Top stars
//            HStack(spacing: 5) {
//                ForEach(0..<5) { _ in
//                    Image(systemName: "star.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.orange)
//                }
//            }
//            .offset(y: -80)
//
//            // Main text (NAFS)
//            Text("NAFS")
//                .font(.system(size: 50, weight: .bold, design: .serif))
//                .foregroundColor(.black)
//                .padding(.top, 20)
//
//            // Bottom text
//            Text("QUIT FOR GOOD")
//                .font(.system(size: 16, weight: .semibold, design: .serif))
//                .foregroundColor(.black)
//                .offset(y: 40)
//        }
//        .padding()
//    }
// }
