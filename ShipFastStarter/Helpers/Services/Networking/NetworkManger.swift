import Foundation
import UIKit

final class NetworkManager: NetworkService {
    private let baseURL = "https://us-central1-colorme-bb0b0.cloudfunctions.net/ai-chat-backend" // Replace with your actual server IP or domain
    static var shared = NetworkManager()

    func sendFitImage(base64: String, isFit: Bool) async throws -> String {
        return try await APINetworkService.requestString(API.sendImage(base64: base64, token: "", isFit: isFit))
    }

    func analyzeImage(base64: String, prompt: String) async throws -> String {
        return try await APINetworkService.requestString(API.analyzeImage(base64: base64, token: "", prompt: prompt))
    }

    func uploadImage(_ image: UIImage) async -> String? {
        do {
            print("Starting image upload")
            let newImage = image.resized(to: CGSize(width: 256, height: 256))
            let imageData = newImage!.jpegData(compressionQuality: 0.4)
            guard let imageData = imageData else {
                print("Failed to convert image to JPEG data")
                return nil
            }

            let url = URL(string: "\(baseURL)/upload-image")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
            body.append("--\(boundary)--\r\n")

            request.httpBody = body

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                throw NetworkError.invalidResponse
            }

            print("Upload response status code: \(httpResponse.statusCode)")

            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                print("Upload failed with status code: \(httpResponse.statusCode)")
                throw NetworkError.invalidResponse
            }

            let uploadResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
            print("Image uploaded successfully, URL: \(uploadResponse.image_url)")

            return uploadResponse.image_url
        } catch {
            print("Error uploading image: \(error)")
            return nil
        }
    }

    struct ImageUploadResponse: Codable {
        let image_url: String
    }

    static func cleanJSONString(input: String) -> String {
        let start = input.firstIndex(of: "{")
        let end = input.lastIndex(of: "}")
        var text: String = input
        if let start = start, let end = end {
            text = String(input[start ... end])
        }
        let lines = text.components(separatedBy: .newlines)
        let jsonLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).starts(with: "```") }
        return jsonLines.joined(separator: "\n")
    }

    func sendChatRequest(messages: [ChatMessage]) async throws -> String {
        guard !messages.isEmpty else {
            throw NetworkError.invalidResponse
        }

        let url = URL(string: "\(baseURL)/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let formattedMessages = messages.map { message -> [String: Any] in
            var formattedContent: [Any] = []
            for content in message.content {
                switch content {
                case let .text(text):
                    formattedContent.append(["type": "text", "text": text])
                case let .image(imageUrl):
                    formattedContent.append([
                        "type": "image_url",
                        "image_url": ["url": imageUrl],
                    ])
                }
            }
            return ["role": message.role, "content": formattedContent]
        }

        let body: [String: Any] = ["messages": formattedMessages]
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decodedResponse.response
    }
}

enum NetworkError: Error {
    case invalidResponse
    case imageConversionFailed
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

protocol NetworkService {
    func sendFitImage(base64: String, isFit: Bool) async throws -> String
    func analyzeImage(base64: String, prompt: String) async throws -> String
    func sendChatRequest(messages: [ChatMessage]) async throws -> String
}

enum MessageContent: Hashable, Codable {
    case text(String)
    case image(String)

    enum CodingKeys: String, CodingKey {
        case type
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .content)
            self = .text(text)
        case "image":
            let imageUrl = try container.decode(String.self, forKey: .content)
            self = .image(imageUrl)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .text(text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .content)
        case let .image(imageUrl):
            try container.encode("image", forKey: .type)
            try container.encode(imageUrl, forKey: .content)
        }
    }
}

struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let role: String
    let content: [MessageContent]

    init(id: UUID = UUID(), role: String, content: [MessageContent]) {
        self.id = id
        self.role = role
        self.content = content
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id && lhs.role == rhs.role && lhs.content == rhs.content
    }
}

struct ChatRequest: Codable {
    let messages: [ChatMessage]
}

struct ChatResponse: Codable {
    let response: String
}
