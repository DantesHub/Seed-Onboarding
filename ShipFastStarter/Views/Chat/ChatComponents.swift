//
//  ChatComponents.swift
//  Kibbe
//
//  Created by Dante Kim on 8/7/24.
//

import MarkdownUI
import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        VStack(alignment: message.role == "user" ? .trailing : .leading) {
            ForEach(message.content, id: \.self) { content in
                switch content {
                case let .text(text):
                    Markdown(text)
                        .markdownTheme(.custom)
                        .padding(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(message.role != "user" ? Color(hex: "#172448").opacity(0.3) : Color.gray.opacity(0.3))
                                .overlay(
                                    SharedComponents.clearShadow
                                )
                        )
                        .foregroundColor(message.role == "user" ? .white : .white)
                        .cornerRadius(12)
                case let .image(imageUrl):
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(10)
                        case let .failure(error):
                            Text("Failed to load image: \(error.localizedDescription)")
                                .foregroundColor(.red)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: 200, maxHeight: 200)
                    .onAppear {
                        print("Attempting to load image from URL: \(imageUrl)")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == "user" ? .trailing : .leading)
        .padding(.horizontal)
    }
}

extension Theme {
    static let custom = Theme()
        .paragraph { configuration in
            configuration.label
                .foregroundColor(.white)
                .overusedFont(weight: .medium, size: .h3p1)
        }
        .listItem { configuration in
            configuration.label
                .foregroundColor(.white)
                .overusedFont(weight: .medium, size: .h3p1)
        }
        .strong {
            ForegroundColor(.white)
            FontWeight(.bold)
        }
        .emphasis {
            ForegroundColor(.white)
            FontStyle(.italic)
        }
        .link {
            ForegroundColor(.blue)
        }
        .heading1 { configuration in
            VStack(alignment: .leading, spacing: 0) {
                configuration.label
                    .foregroundColor(.white)
                    .font(.system(.title).bold())
                    .padding(.bottom, 8)
                Divider().background(Color.white)
            }
        }
        .heading2 { configuration in
            configuration.label
                .foregroundColor(.white)
                .font(.system(.title2).bold())
        }
        .heading3 { configuration in
            configuration.label
                .foregroundColor(.white)
                .font(.system(.title3).bold())
        }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.images.append(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

struct GrowingTextView: UIViewRepresentable {
    @Binding var text: String
    var minHeight: CGFloat
    var maxHeight: CGFloat
    @Binding var height: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        textView.backgroundColor = UIColor(named: "#070921")
        textView.layer.cornerRadius = 20
        textView.clipsToBounds = true
        textView.textColor = UIColor.white
        // Increase the text container insets for more padding
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        textView.translatesAutoresizingMaskIntoConstraints = false

        // Set fixed width constraint
        textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7).isActive = true

        return textView
    }

    func updateUIView(_ uiView: UITextView, context _: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()

        DispatchQueue.main.async {
            let size = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            let newHeight = max(minHeight, min(maxHeight, size.height))
            if height != newHeight {
                height = newHeight
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextView

        init(_ parent: GrowingTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            let newHeight = max(parent.minHeight, min(parent.maxHeight, size.height))
            if parent.height != newHeight {
                parent.height = newHeight
            }
        }
    }
}

import Combine

struct LoadingBubble: View {
    @State private var animationAmount = 0.0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< 3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
                    .scaleEffect(animationAmount)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationAmount
                    )
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
        .onAppear {
            animationAmount = 1
        }
    }
}

struct PromptsSheet: View {
    @Binding var prompts: [String]
    @EnvironmentObject var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            viewModel.showPrompts = false
                        }
                    }
                Spacer()
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .opacity(0)
            }.padding()
            ForEach(prompts, id: \.self) { prompt in
                Text(prompt)
                    .sfFont(weight: .medium, size: .p2)
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 72)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(32)
                    .padding(.vertical, 8)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        Analytics.shared.logActual(event: "ChatScreen: Tapped Prompt", parameters: ["prompt": prompt])
                        viewModel.inputMessage = prompt
                        isInputFocused = true
                    }
            }
            Spacer()
        }.padding()
    }
}
