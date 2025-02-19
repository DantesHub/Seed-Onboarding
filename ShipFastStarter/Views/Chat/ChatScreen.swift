import SuperwallKit
import SwiftUI

struct ChatScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @ObservedObject var viewModel: ChatViewModel
    @State private var showingImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var scrollProxy: ScrollViewProxy?

    @State private var inputRowHeight: CGFloat = 60 // Increased initial height
    @State private var keyboardHeight: CGFloat = 0

    @State private var prompts = Constants.chatPrompts
    @FocusState private var isInputFocused: Bool
    let tabBarHeight: CGFloat = UIScreen.main.bounds.height / 10

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(.justBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                KeyboardAvoidanceView(keyboardHeight: $keyboardHeight) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Chat")
                                .overusedFont(weight: .semiBold, size: .h1Big)
                                .foregroundColor(.white)
                            Spacer()
                            if !viewModel.messages.filter({ $0.role != "system" }).isEmpty {
                                Image(systemName: "list.bullet.clipboard.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.white)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        viewModel.showPrompts = true
                                    }
                            }

                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                                .onTapGesture {
                                    withAnimation {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        homeVM.showChat = false
                                    }
                                }
                                .foregroundColor(Color.white)
                                .padding(.leading)

                        }.padding(.horizontal, 28)
                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                LazyVStack(spacing: 15) {
                                    if viewModel.messages.filter({ $0.role != "system" }).isEmpty {
                                        promptsView
                                    } else {
                                        messagesView
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: viewModel.messages) { _ in
                                if let lastId = viewModel.messages.last?.id {
                                    withAnimation(.spring()) {
                                        proxy.scrollTo(lastId, anchor: .bottom)
                                    }
                                }
                            }
                        }

                        inputArea
                            .padding(.bottom, max(keyboardHeight > 0 ? keyboardHeight : 0, geometry.safeAreaInsets.bottom))
                    }
                }
            }

        }.edgesIgnoringSafeArea(.bottom)
            .onTapGesture { dismissKeyboard() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(images: $selectedImages)
                    .edgesIgnoringSafeArea(.all)
            }
            .sheet(isPresented: $viewModel.showPrompts) {
                promptsSheet
            }
            .onAppear {
                isInputFocused = true
            }
    }

    private var promptsView: some View {
        VStack {
            Text("Suggested Prompts")
                .overusedFont(weight: .medium, size: .p2)
                .foregroundColor(Color.primaryBlue)
            ForEach(prompts, id: \.self) { prompt in
                promptButton(prompt)
            }
        }
    }

    private var messagesView: some View {
        Group {
            ForEach(viewModel.messages.filter { $0.role != "system" }) { message in
                MessageBubble(message: message)
                    .id(message.id)
            }
            if viewModel.isLoading {
                LoadingBubble()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
        }
    }

    private var inputArea: some View {
        VStack(spacing: 10) {
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack(spacing: 8) {
                if isInputFocused {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismissKeyboard()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.white)
                            .frame(width: 20, height: 20)
                    }
                    .padding(.leading, 8)
                }

                GrowingTextView(text: $viewModel.inputMessage, minHeight: 40, maxHeight: 160, height: $inputRowHeight)
                    .frame(height: inputRowHeight)
                    .focused($isInputFocused)
                Image(systemName: "arrow.up")
                    .bold()
                    .foregroundColor(Color(hex: "#172448"))
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .background(Color.primaryBlue)
                    .cornerRadius(20)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        sendMessage()
                    }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#172448").opacity(0.3))
                .overlay(
                    SharedComponents.clearShadow
                )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }

    private func promptButton(_ prompt: String) -> some View {
        Text(prompt)
            .overusedFont(weight: .medium, size: .p2)
            .padding()
            .multilineTextAlignment(.center)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        SharedComponents.clearShadow
                    )
            )
            .foregroundColor(Color.primaryForeground)
            .cornerRadius(24)
            .padding(.vertical, 8)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                Analytics.shared.logActual(event: "ChatScreen: Tapped Prompt", parameters: ["prompt": prompt])
                viewModel.inputMessage = prompt
                isInputFocused = true
            }
    }

    private var promptsSheet: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            viewModel.showPrompts = false
                        }
                        .foregroundColor(Color.white)

                    Spacer()
                    Text("Suggested Prompts")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .opacity(0)
                }.padding()
                    .padding(.top, 64)
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(prompts, id: \.self) { prompt in
                            promptButton(prompt)
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
        .frame(height: UIScreen.main.bounds.height)
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func sendMessage() {
        Analytics.shared.log(event: "ChatScreen: Tapped Send")

        var numMessages = UserDefaults.standard.integer(forKey: "numMessages")
        numMessages += 1
        UserDefaults.standard.setValue(numMessages, forKey: "numMessages")
        if !viewModel.inputMessage.isEmpty {
            let messageToSend = viewModel.inputMessage // Store the message locally
            let imagesToSend = selectedImages

            Task {
                viewModel.inputMessage = messageToSend
                await viewModel.sendMessage(images: imagesToSend)
                viewModel.inputMessage = "" // Clear the input message
            }
        }
        if numMessages > 3 && !mainVM.isPro {
//            Analytics.shared.log(event: "ChatScreen: Triggered Paywall")
//            if mainVM.showHalfOff {
//                Superwall.shared.register(event: "chat_trigger_half")
//            } else {
//                Superwall.shared.register(event: "chat_trigger")
//            }
        } else {}
    }
}

import Combine

struct KeyboardAvoidanceView<Content: View>: View {
    @Binding var keyboardHeight: CGFloat
    let content: () -> Content

    @State private var keyboardObserver: AnyCancellable?

    var body: some View {
        content()
            .onAppear {
                keyboardObserver = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
                    .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
                    .compactMap { notification -> CGFloat? in
                        if notification.name == UIResponder.keyboardWillHideNotification {
                            return 0
                        }
                        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                            return nil
                        }
                        return keyboardFrame.height
                    }
                    .subscribe(on: RunLoop.main)
                    .sink { height in
                        withAnimation(.easeOut(duration: 0.16)) {
                            self.keyboardHeight = height
                        }
                    }
            }
            .onDisappear {
                keyboardObserver?.cancel()
            }
    }
}

// import MarkdownUI
//
// struct MessageBubble: View {
//    let message: ChatMessage
//    @State private var markdown = """
//      ## Try GitHub Flavored Markdown
//
//      You can try **GitHub Flavored Markdown** here.  This dingus is powered
//      by [MarkdownUI](https://github.com/gonzalezreal/MarkdownUI), a native
//      Markdown renderer for SwiftUI.
//
//      1. item one
//      1. item two
//         - sublist
//         - sublist
//      """
//
//
//    var body: some View {
//        HStack {
//            if message.role == "user" {
//                Spacer()
//            }
//            VStack(alignment: .leading, spacing: 4) {
//                Markdown(markdown)
//                    .padding()
//                    .background(message.role == "user" ? Color.blue : Color.gray)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//            }
//            if message.role == "assistant" {
//                Spacer()
//            }
//        }.onAppear {
//            markdown = """
//            \(message.content)
//            """
//        }
//    }
// }
