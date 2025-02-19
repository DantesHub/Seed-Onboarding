//
//  SharedComponents.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import Foundation
import PencilKit
import SwiftUI

struct GrayPrimaryButton: View {
    var title: String
    var action: () -> Void
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray)
                .stroke(Color.black.opacity(0.3), lineWidth: 2)
                .shadow(color: Color.black.opacity(0.2), radius: 3)
                .frame(height: 50)
                .scaleEffect(opacity == 1 ? 1 : 0.95)
                .opacity(opacity)
            Text(title)
                .foregroundColor(.white)
                .sfFont(weight: .medium, size: .h3p1)
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.opacity = 0.7
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
                    self.opacity = 1
                    self.action()
                }
            }
        }
    }
}

enum SharedComponents {
    static func mainButton(title: String, action: @escaping () -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primaryPurple)
                .stroke(.black, lineWidth: 2)
                .shadow(color: Color.black.opacity(0.2), radius: 3)
//                .primaryShadow()
            Text(title)
                .sfFont(weight: .semibold, size: .h3p1)
                .foregroundColor(Color.white)
        }
        .frame(height: 56)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation {
                action()
            }
        }
    }

    static func linearGradient() -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 339, height: 312)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.21, green: 0.21, blue: 0.64), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.58, green: 0.48, blue: 0.87), location: 0.45),
                        Gradient.Stop(color: Color(red: 0.89, green: 0.89, blue: 0.93), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                ))
            .cornerRadius(339)
            .blur(radius: 100)
            .offset(y: 100)
    }

    struct PrimaryButton: View {
        var img: Image?
        var title: String = "Continue2"
        var isDisabled: Bool
        @State private var opacity: Double = 1
        var action: () -> Void
        var isPurple: Bool = false

        init(img: Image? = nil, title: String = "Continue2", action: @escaping () -> Void, isDisabled: Bool = false) {
            self.img = img
            self.title = title
            self.action = action
            self.isDisabled = isDisabled
        }

        var body: some View {
            ZStack {
                if isPurple {
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(SharedComponents.Gradients.primary)
                        .stroke(Color.black.opacity(0.3), lineWidth: 2)
                        .shadow(color: Color.black.opacity(0.2), radius: 3)
                        .frame(height: 72)
                        .scaleEffect(opacity == 1 ? 1 : 0.95)
                        .opacity(opacity)
                }

                HStack {
                    Spacer()
                    Text(title)
                        .foregroundColor(.white)
                        .overusedFont(weight: .medium, size: .h3p1)
                    Spacer()
                    if let img = img {
                        img
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .bold()
                    }
                }.padding(.horizontal, 32)
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.opacity = 0.7
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring()) {
                        self.opacity = 1
                        self.action()
                    }
                }
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1)
        }
    }

    struct CustomText: View {
        let title: String
        let font: Font
        let color: Color
        var body: some View {
            Text(title)
                .font(font)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct HomePopsButton: View {
        var action: () -> Void
        var body: some View {
            VStack {
                Button(action: {
                    // Handle button action
                }) {
                    Text("dhikr°")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 0.1, green: 0.5, blue: 0.4))
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }

    struct CustomBoldText: View {
        let title: String
        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .bold, size: .h2)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomExtraBoldHeading: View {
        let title: String
        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .bold, size: .h1Big)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomMediumTwenty: View {
        let title: String
        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .medium, size: .h3p1)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomSmallMediumText: View {
        let title: String
        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .medium, size: .p2)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomBoldHeading: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .semiBold, size: .h1)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomExtraSemiboldHeading: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .semiBold, size: .h1Big)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct HomeDankherButton: View {
        let title: String
        let action: () -> Void
        let color: [Color]
        var body: some View {
            HStack {
                Spacer()
                CustomMediumTwenty(title: title, color: .white)
                Image(.dhiker)
                    .scaledToFit()

                Spacer()
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }
            .padding()
            .frame(height: 105)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: color[0], location: 0.00),
                        Gradient.Stop(color: color[1], location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.49, y: 0.04),
                    endPoint: UnitPoint(x: 0.5, y: 1.25)
                )
            )
            .overlay(SharedComponents.clearShadow)
            .cornerRadius(24)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation {
                    action()
                }
            }
        }
    }

    struct HomeRelapsedButton: View {
        let title: String
        let action: () -> Void
        let color: [Color]
        var height: CGFloat = 105.0
        var body: some View {
            HStack {
                Spacer()
                if height == 100 {
                    Text(title)
                        .overusedFont(weight: .black, size: .h1Big)
                } else {
                    CustomMediumTwenty(title: title, color: .white)
                }

                Spacer()
            }
            .padding()
            .frame(height: height)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: color[0], location: 0.00),
                        Gradient.Stop(color: color[1], location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.49, y: 0.04),
                    endPoint: UnitPoint(x: 0.5, y: 1.25)
                )
            )
            .overlay(SharedComponents.clearShadow)
            .cornerRadius(24)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation {
                    action()
                }
            }
        }
    }

    struct CustomSubtitleText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .medium, size: .h3p1)
                .foregroundColor(color)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomMediumText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .medium, size: .h2)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomSemiboldText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .semiBold, size: .titleHundred)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomVerySmallMediumText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .medium, size: .p7)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct customVerySmallMediumText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .medium, size: .p4)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomLightText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .light, size: .p3)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    static var clearShadow: some View {
        return Group {
            if #available(iOS 18, *) {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1),
                            lineWidth: 6)
                    .shadow(color: Color.white,
                            radius: 2, x: 3, y: 6)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )
                    .shadow(color: Color.white, radius: 3, x: -4, y: -2)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1),
                            lineWidth: 6)
                    .shadow(color: Color.white.opacity(0.1),
                            radius: 2, x: 3, y: 6)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )
                    .shadow(color: Color.white.opacity(0.1), radius: 3, x: -4, y: -2)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )
            }
        }
    }

    struct CustomMediumSmallMediumText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .medium, size: .p2)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomBoldTitleText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .bold, size: .titlebold)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomSemiBoldTitleText: View {
        let title: String

        let color: Color
        var body: some View {
            Text(title)
                .overusedFont(weight: .bold, size: .titlebold)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct CustomStrokeText: View {
        let title: String
        let color: [Color]
        let strokeColor: Color

        var body: some View {
            StrokeText(text: title, width: 1, color: Color(hex: "#00B7FF"))
                .overusedFont(weight: .bold, size: .statNumber)
                .foregroundStyle(
                    LinearGradient(
                        colors: [color[0], color[1]],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: title)
        }
    }

    struct OnboardVoteOption: View {
        let title: String
        let height: CGFloat
        var body: some View {
            Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .overusedFont(weight: .medium, size: .h3p1)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.44, green: 0.45, blue: 1), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.1, green: 0.13, blue: 0.81), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                    .cornerRadius(24))
        }
    }

    struct OnboardingButton: View {
        let title: String
        let font: Font
        let buttonAction: () -> Void
        @State private var selected = false

        var body: some View {
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                buttonAction()

            }) {
                Text(title)
                    .font(font)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        SharedComponents.Gradients.primary
                            .clipShape(Capsule())
                            // First Inner Shadow
                            .background(
                                SharedComponents.Gradients.primary
                                    .clipShape(Capsule())
                            )
                    )
            }
            .frame(height: 60)
            .animation(.easeInOut(duration: 0.5), value: title)
            .padding(.horizontal, 30)
        }
    }

    enum Gradients {
        static let primary = LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.44, green: 0.45, blue: 1), location: 0.00),
                Gradient.Stop(color: Color(red: 0.1, green: 0.13, blue: 0.81), location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )

        static let selected = LinearGradient(
            colors: [Color(red: 0.07, green: 0.08, blue: 0.47), Color(red: 0.1, green: 0.13, blue: 0.81)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    ZStack {
        Color.black
        SharedComponents.PrimaryButton(title: "Start rewiring for free") {}
    }
}

import SwiftUI

struct InnerShadow<S: Shape>: View {
    var shape: S
    var color: Color
    var offsetX: CGFloat
    var offsetY: CGFloat
    var blur: CGFloat
    var spread: CGFloat
    var opacity: Double

    var body: some View {
        let scale = 1 + (spread / 100)
        let adjustedShape = shape.scale(scale)

        return ZStack {
            adjustedShape
                .fill(Color.clear)
                .overlay(
                    adjustedShape
                        .stroke(color.opacity(0.0001), lineWidth: abs(spread))
                        .shadow(color: color.opacity(opacity), radius: blur, x: offsetX, y: offsetY)
                        .clipShape(adjustedShape)
                        .blendMode(.sourceAtop)
                )
        }
    }
}

extension View {
    func innerShadow(
        color: Color = .black,
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0,
        opacity: Double = 1.0
    ) -> some View {
        overlay(
            mask(
                overlay(
                    Rectangle()
                        .fill(color)
                        .blendMode(.sourceAtop)
                )
                .blur(radius: radius)
                .offset(x: x, y: y)
            )
        )
        .opacity(opacity)
    }
}

//    struct CustomTextEditor: View {
//        @Binding var text: String
//        var placeholder: String
//
//        var body: some View {
//            ZStack(alignment: .topLeading) {
//                if text.isEmpty {
//                    Text(placeholder)
//                        .foregroundColor(.gray)
//                        .padding(10)
//                        .overusedFont(weight: .medium, size: .h3p1)
//
//                }
//                TextEditor(text: $text)
//                    .padding(10)
//                    .overusedFont(weight: .medium, size: .h3p1)
//
//                    .scrollContentBackground(.hidden) // <- Hide it
//                    .background(Color.clear)
//                    .cornerRadius(17)
//                    .shadow(color: Color(red: 0, green: 0.72, blue: 1).opacity(0.25), radius: 50, x: 0, y: 4)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 17)
//                            .inset(by: 0.5)
//
//                            .stroke(Color(red: 0.13, green: 0.15, blue: 0.53), lineWidth: 1)
//                    )
//                    .foregroundColor(.white)  // Text color for dark background
//            }
//        }
//    }

struct CustomTextEditor: View {
    @Binding var text: String
    var placeholder: String
    @State var speechAnalyzer: SpeechAnalyzer
    var action: () -> Void
    @FocusState private var isFocused: Bool

    // Define the character limit
    private let characterLimit = 300

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder text
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(10)
                    .padding(.leading, 8)
                    .overusedFont(weight: .medium, size: .p5)
            }

            // TextEditor
            TextEditor(text: $text)
                .padding(.horizontal, 10)
                .padding(.bottom, 50) // Padding to prevent text overlap with the button
                .overusedFont(weight: .medium, size: .p5)
                .scrollContentBackground(.hidden) // Hide the scroll background
                .background(Color.clear)
                .cornerRadius(17)
                .shadow(color: Color(red: 0, green: 0.72, blue: 1).opacity(0.25), radius: 50, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 17)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.13, green: 0.15, blue: 0.53), lineWidth: 1)
                )
                .foregroundColor(.white) // Text color for dark background
                .focused($isFocused) // Add this line

            // Button container
            VStack {
                Spacer() // Pushes the buttons to the bottom
                HStack {
                    // Microphone button on the left
                    Button(action: {
                        action()
                    }) {
                        Image(systemName: "mic.fill") // Use a microphone icon
                            .frame(width: 40, height: 40) // Same size as the counter button
                            .foregroundColor(speechAnalyzer.isProcessing ? .red : Color(hex: "#444FFFBF"))
                            .aspectRatio(contentMode: .fit)
                            .background(Color(hex: "#444FFF33").opacity(0.20)) // Background color for the button
                            .clipShape(Circle()) // Make the button circular
                            .overlay(Circle().stroke(Color(red: 0.13, green: 0.15, blue: 0.53), lineWidth: 1)) // Blue border
                    }
                    .padding(.leading, 10) // Add some padding to the left of the button
                    .padding(.bottom, 10) // Add some bottom padding to the button

                    Spacer() // Push the character limit button to the right

                    // Character limit display button on the right
                    Button(action: {
                        // Action for showing character limit (you can add functionality here)
                    }) {
                        // Calculate remaining characters
                        let remainingCharacters = characterLimit - text.count

                        Text("\(remainingCharacters)")
                            .overusedFont(weight: .medium, size: .p6)
                            .frame(width: 40, height: 40) // Same size as the mic button
                            .background(Color.clear) // Transparent background
                            .clipShape(Circle()) // Make the button circular
                            .overlay(Circle().stroke(remainingCharacters < 0 ? Color.red : Color(red: 0.13, green: 0.15, blue: 0.53), lineWidth: 1)) // Border changes color when over limit
                            .foregroundColor(remainingCharacters < 0 ? .red : Color.blue) // Set text color based on character count
                    }
                    .padding(.trailing, 10) // Add some padding to the right of the button
                    .padding(.bottom, 10) // Add some bottom padding to the button
                }
            }
        }
        .frame(maxHeight: .infinity) // Ensure it uses the available height
    }
}

// struct CustomTextEditor: View {
//    @Binding var text: String
//    var placeholder: String
//    @State var speechAnalyzer: SpeechAnalyzer
//    var action: () -> Void
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            // Placeholder text
//            if text.isEmpty {
//                Text(placeholder)
//                    .foregroundColor(.gray)
//                    .padding(10)
//                    .overusedFont(weight: .medium, size: .p5)
//            }
//
//            // TextEditor
//            TextEditor(text: $text)
//                .padding(.horizontal, 10)
//                .padding(.bottom, 50) // Padding to prevent text overlap with the button
//                .overusedFont(weight: .medium, size: .p5)
//                .scrollContentBackground(.hidden) // Hide the scroll background
//                .background(Color.clear)
//                .cornerRadius(17)
//                .shadow(color: Color(red: 0, green: 0.72, blue: 1).opacity(0.25), radius: 50, x: 0, y: 4)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 17)
//                        .inset(by: 0.5)
//                        .stroke(Color(red: 0.13, green: 0.15, blue: 0.53), lineWidth: 1)
//                )
//                .foregroundColor(.white) // Text color for dark background
//
//            // Microphone button
//            VStack {
//                Spacer() // Pushes the button to the bottom
//                HStack {
//                    Spacer() // Push the button to the right
//                    Button(action: {
//                        action()
//                    }) {
//                        Image(systemName: "mic.fill") // Use a microphone icon
//                            .frame(width: 15, height: 15) // Adjust the size of the icon
//                            .foregroundColor(speechAnalyzer.isProcessing ? .red : Color(hex: "#444FFFBF"))
//                            .aspectRatio(contentMode: .fit)
//                            .padding()
//                            .background(Color(hex: "#444FFF33").opacity(0.20)) // Background color for the button
//                            .clipShape(Circle()) // Make the button circular
//                            .overlay(Circle().stroke(Color(red: 0.13, green: 0.15, blue: 0.53), lineWidth: 1)) // Blue border
//                    }
//                    .padding(.bottom, 10) // Add some bottom padding to the button
//                    .padding(.trailing, 10) // Add some padding to the right
//                }
//            }
//        }
//        .frame(maxHeight: .infinity) // Ensure it uses the available height
//    }
// }

// struct CustomTextEditor: View {
//    @Binding var text: String
//    var placeholder: String
//    @State var speechAnalyzer: SpeechAnalyzer
//    var action: () -> Void
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            // Placeholder text
//            if text.isEmpty {
//                Text(placeholder)
//                    .foregroundColor(.gray)
//                    .padding(10)
//                    .overusedFont(weight: .medium, size: .p5)
//            }
//
//            // TextEditor
//            TextEditor(text: $text)
//                .padding(10)
//                .overusedFont(weight: .medium, size: .p5)
//                .scrollContentBackground(.hidden) // Hide the scroll background
//                .background(Color.clear)
//
//                .cornerRadius(17)
//                .shadow(color: Color(red: 0, green: 0.72, blue: 1).opacity(0.25), radius: 50, x: 0, y: 4)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 17)
//                        .inset(by: 0.5)
//                        .stroke(Color(red: 0.13, green: 0.15, blue: 0.53), lineWidth: 1)
//                )
//                .foregroundColor(.white) // Text color for dark background
//
//            // Microphone button
//            VStack {
//                Spacer() // Pushes the button to the bottom
//                HStack {
//                    Button(action: {
//                        action()
//
//                    }) {
//                        Image(systemName: "mic.fill") // Use a microphone icon
//                            .resizable()
//                            .background(.white)
//                            .frame(width: 12, height: 12) // Set the size of the icon
//                            .foregroundColor(speechAnalyzer.isProcessing ? .red : .gray)
//                            .aspectRatio(contentMode: .fit)
//                            .padding()
//                    }
//                    .padding(.leading, 10) // Add some padding to the left
//                }
//            }
//        }
//    }
// }

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            ZStack {
                Text(text).offset(x: width, y: width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y: width)
                Text(text).offset(x: width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}



struct PKCanvasRepresentation: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var isCanvasEmpty: Bool
    @Binding var hasStartedDrawing: Bool // Add this binding

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .white, width: 1)
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_: PKCanvasView, context _: Context) {
        // No updates required here
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PKCanvasRepresentation

        init(_ parent: PKCanvasRepresentation) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.isCanvasEmpty = canvasView.drawing.strokes.isEmpty
            if !canvasView.drawing.strokes.isEmpty {
                parent.hasStartedDrawing = true
            }
        }
    }
}

//
//
// struct SignatureView: View {
//    @State private var canvasView = PKCanvasView()
//    @State private var signatureImage: UIImage?
//    @State private var isCanvasEmpty = true
//
//    var body: some View {
//        VStack {
//            ZStack(alignment: .topLeading) { // Align the placeholder text to top-left
//                PKCanvasRepresentation(canvasView: $canvasView, isCanvasEmpty: $isCanvasEmpty)
//                    .frame(height: 160)
//                    .background(Color(hex: "070921"))
//
//                    .cornerRadius(24) // Apply corner radius to prevent cutting off
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 24)
//                            .stroke(Color(hex: "212786"), lineWidth: 1)
//                    )
//                    .shadow(color: Color(hex: "00B7FF").opacity(0.25), radius: 10, x: 0, y: 4) // Shadow of the border color
//
//                if isCanvasEmpty {
//                    SharedComponents.CustomSmallMediumText(title: "Sign your name using finger", color: (Color(hex: "070921")))
//                        .padding([.top, .leading], 16) // Adjust position to top-left
//                }
//            }
//            .padding()
//
//            if let signatureImage = signatureImage {
//                Image(uiImage: signatureImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 240)
//                    .padding()
//            }
//        }
//
//    }
// }
//
// struct PKCanvasRepresentation: UIViewRepresentable {
//    @Binding var canvasView: PKCanvasView
//    @Binding var isCanvasEmpty: Bool
//
//    func makeUIView(context: Context) -> PKCanvasView {
//        canvasView.tool = PKInkingTool(.pen, color: .white, width: 1)
//        canvasView.drawingPolicy = .anyInput // Allows both finger and Apple Pencil input
//        canvasView.backgroundColor = .clear
//        canvasView.delegate = context.coordinator
//        return canvasView
//    }
//
//    func updateUIView(_ uiView: PKCanvasView, context: Context) {
//        // No updates required here
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, PKCanvasViewDelegate {
//        var parent: PKCanvasRepresentation
//
//        init(_ parent: PKCanvasRepresentation) {
//            self.parent = parent
//        }
//
//        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//            // Check if the drawing is empty
//            parent.isCanvasEmpty = canvasView.drawing.strokes.isEmpty
//        }
//    }
// }
//
//
//
//
// extension PKCanvasView {
//    func asImage() -> UIImage {
//        let renderer = UIGraphicsImageRenderer(bounds: bounds)
//        return renderer.image { context in
//            layer.render(in: context.cgContext)
//        }
//    }
// }
