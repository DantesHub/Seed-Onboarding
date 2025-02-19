//
//  User.swift
//  NoFap
//
//  Created by Dante Kim on 7/10/24.
//

import Foundation
import SwiftData

protocol FBObject {
    var id: String { get }
    func encodeToDictionary() -> [String: Any]?
}

@Model
final class User: Codable, Identifiable, FBObject {
    var id: String = UUID().uuidString
    var joinDate: String = Date().toString()
    var email: String = ""
    var isPro: Bool = false
    var currentStreak: Int = 0
    var currentOrb: String = ""
    var name: String = ""
    var religion: String = ""
    var age: String = ""
    var completedLessons: [Int] = []
    var minsSavedPerDay: Double = 0.0
    var gender: String = ""
    var userExercises: [String: String] = [:]
    var appleToken: String = ""
    var howOften: String = ""
    var challenges: [String: String] = [:]
    var moods: [String: String] = [:]
    var onboardingQuestions: [String: String] = [:] // New property
    var rewards: [String: String] = [:] // Add this line
    var collectedOrbs: [String] = [] // Fixed naming
    
    init(id: String = UUID().uuidString,
         joinDate: String = Date().toString(),
         email: String = "",
         isPro: Bool = false,
         currentStreak: Int = 0,
         currentOrb: String = "",
         name: String = "",
         religion: String = "",
         age: String = "",
         completedLessons: [Int] = [],
         minsSavedPerDay: Double = 0.0,
         gender: String = "",
         userExercises: [String: String] = [:],
         appleToken: String = "",
         howOften: String = "",
         challenges: [String: String] = [:],
         moods: [String: String] = [:],
         onboardingQuestions: [String: String] = [:],
         rewards: [String: String] = [:],
         collectedOrbs: [String] = [] // Fixed naming
    ) {
        self.id = id
        self.joinDate = joinDate
        self.email = email
        self.isPro = isPro
        self.currentStreak = currentStreak
        self.currentOrb = currentOrb
        self.name = name
        self.religion = religion
        self.age = age
        self.completedLessons = completedLessons
        self.minsSavedPerDay = minsSavedPerDay
        self.gender = gender
        self.userExercises = userExercises
        self.appleToken = appleToken
        self.howOften = howOften
        self.challenges = challenges
        self.moods = moods
        self.onboardingQuestions = onboardingQuestions // Initialize new property
        self.rewards = rewards // Add this line
        self.collectedOrbs = collectedOrbs // Fixed naming
    }

    static var exUser = User(id: UUID().uuidString, joinDate: "", email: "", isPro: false, currentStreak: 0, currentOrb: "originalSeed", name: "", religion: "", age: "", completedLessons: [], minsSavedPerDay: 0.5, gender: "", userExercises: [:], appleToken: "", howOften: "", challenges: [:], moods: [:], onboardingQuestions: [:], rewards: [:], collectedOrbs: [])

    func userDetails() -> String {
        return """
        Users name \(name)
        Users religion is \(religion)
        User is this age range \(age)
        User's gender \(gender)
        User is currently saving \(minsSavedPerDay) minutes per day by abstaining.
        User's exercises \(userExercises)
        """
    }

    static func getExerciseAndDate(fromString: String) -> (String, String) {
        let components = fromString.components(separatedBy: "+")
        guard components.count == 2 else {
            return ("", "")
        }
        let date = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let exercise = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return (date, exercise)
    }

    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(joinDate, forKey: .joinDate)
        try container.encode(email, forKey: .email)
        try container.encode(isPro, forKey: .isPro)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(currentOrb, forKey: .currentOrb)
        try container.encode(name, forKey: .name)
        try container.encode(religion, forKey: .religion)
        try container.encode(age, forKey: .age)
        try container.encode(completedLessons, forKey: .completedLessons)
        try container.encode(minsSavedPerDay, forKey: .minsSavedPerDay)
        try container.encode(gender, forKey: .gender)
        try container.encode(userExercises, forKey: .userExercises)
        try container.encode(appleToken, forKey: .appleToken)
        try container.encode(howOften, forKey: .howOften)
        try container.encode(challenges, forKey: .challenges)
        try container.encode(moods, forKey: .moods)
        try container.encode(onboardingQuestions, forKey: .onboardingQuestions)
        try container.encode(rewards, forKey: .rewards)
        try container.encode(collectedOrbs, forKey: .collectedOrbs) // Fixed naming
    }

    // Decoding
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        joinDate = try container.decode(String.self, forKey: .joinDate)
        email = try container.decode(String.self, forKey: .email)
        isPro = try container.decode(Bool.self, forKey: .isPro)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        currentOrb = try container.decode(String.self, forKey: .currentOrb)
        name = try container.decode(String.self, forKey: .name)
        religion = try container.decode(String.self, forKey: .religion)
        age = try container.decode(String.self, forKey: .age)
        completedLessons = try container.decode([Int].self, forKey: .completedLessons)
        minsSavedPerDay = try container.decode(Double.self, forKey: .minsSavedPerDay)
        gender = try container.decode(String.self, forKey: .gender)
        userExercises = try container.decode([String: String].self, forKey: .userExercises)
        appleToken = try container.decode(String.self, forKey: .appleToken)
        howOften = try container.decode(String.self, forKey: .howOften)
        challenges = try container.decode([String: String].self, forKey: .challenges)
        moods = try container.decode([String: String].self, forKey: .moods)
        onboardingQuestions = try container.decode([String: String].self, forKey: .onboardingQuestions)
        rewards = try container.decode([String: String].self, forKey: .rewards)
        collectedOrbs = try container.decodeIfPresent([String].self, forKey: .collectedOrbs) ?? [] // Fixed naming
    }

    enum CodingKeys: String, CodingKey {
        case id, joinDate, email, isPro, currentStreak, currentOrb, name, religion, age, completedLessons, minsSavedPerDay, gender, userExercises, appleToken, howOften, challenges, moods, onboardingQuestions, rewards, collectedOrbs
    }

    // Implement encodeToDictionary for FBObject protocol
    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding User to dictionary: \(error)")
            return nil
        }
    }

    static var schema: Schema {
        Schema(
            [
                User.self,
            ],
            version: Schema.Version(2, 0, 0)
        )
    }

    func updateFromFirebase(fbUser: User) {
        self.id = fbUser.id
        self.joinDate = fbUser.joinDate
        self.email = fbUser.email
        self.isPro = fbUser.isPro
        self.currentStreak = fbUser.currentStreak
        self.currentOrb = fbUser.currentOrb
        self.name = fbUser.name
        self.religion = fbUser.religion
        self.age = fbUser.age
        self.completedLessons = fbUser.completedLessons
        self.minsSavedPerDay = fbUser.minsSavedPerDay
        self.gender = fbUser.gender
        self.userExercises = fbUser.userExercises
        self.appleToken = fbUser.appleToken
        self.howOften = fbUser.howOften
        self.challenges = fbUser.challenges
        self.moods = fbUser.moods
        self.onboardingQuestions = fbUser.onboardingQuestions
        self.rewards = fbUser.rewards
        self.collectedOrbs = fbUser.collectedOrbs
    }
}
