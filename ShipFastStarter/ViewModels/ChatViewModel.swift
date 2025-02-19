import Foundation
import SwiftUI
import UIKit

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage: String = ""
    @Published var showPrompts = false
    @Published var isLoading = false

    init() {}

    func addSystemPrompt(userInfo: String) {
        var systemPrompt = """
        You are a self-improvement coach similar to Tony Robbins. Your main role is to help the user quit pornography. Try to use a CBT approach instead of sending large amounts of text at once. Make sure to use their name whenever you get the chance

        \(userInfo)
        """

        let systemMessage = ChatMessage(role: "system", content: [.text(systemPrompt)])
        messages.append(systemMessage)
    }

    func sendMessage(images: [UIImage] = []) async {
        isLoading = true
        var content = [MessageContent]()

        if !inputMessage.isEmpty {
            content.append(.text(inputMessage))
            inputMessage = ""
        }

        for image in images {
            if let imageUrl = await uploadImage(image) {
                content.append(.image(imageUrl))
            }
        }

        guard !content.isEmpty else {
            print("No content to send.")
            return
        }

        let userMessage = ChatMessage(role: "user", content: content)

        withAnimation(.spring()) {
            self.messages.append(userMessage)
        }

        do {
            // Include all messages, including the system prompt
            let response = try await NetworkManager.shared.sendChatRequest(messages: messages)
            let assistantMessage = ChatMessage(role: "assistant", content: [.text(response)])

            withAnimation(.spring()) {
                self.messages.append(assistantMessage)
                self.isLoading = false
            }
        } catch {
            print("Error: \(error)")
            DispatchQueue.main.async {
                self.messages.append(ChatMessage(role: "assistant", content: [.text("An error occurred. Please try again.")]))
                self.isLoading = false
            }
        }
    }

    private func uploadImage(_ image: UIImage) async -> String? {
        do {
            return try await NetworkManager.shared.uploadImage(image)
        } catch {
            print("Error uploading image: \(error)")
            return nil
        }
    }
}
