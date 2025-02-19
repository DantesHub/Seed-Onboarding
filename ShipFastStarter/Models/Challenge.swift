//
//  Challenge.swift
//  Resolved
//
//  Created by Dante Kim on 10/17/24.
//

import FirebaseFirestore
import Foundation

struct Challenge: Codable, Identifiable, FBObject {
    var id: String
    var title: String
    var participants: Int
    var challengers: Int
    var failedParticipants: Int
    var description: String
    var startDate: Date
    var endDate: Date
    var length: Int
    var currentStatus: String
    var noRelapse: Int
    var oneRelapse: Int
    var twoRelapse: Int
    var threeRelapse: Int
    var fourRelapse: Int
    var fiveRelapse: Int
    var sixRelapse: Int

    func zeroRelapse() -> Int {
        return challengers - oneRelapse - twoRelapse - threeRelapse - fourRelapse - fiveRelapse - sixRelapse
    }

    init(id: String,
         title: String,
         participants: Int,
         challengers: Int,
         failedParticipants: Int,
         description: String,
         startDateString: String,
         endDateString: String,
         length: Int,
         currentStatus: String = "Join Challenge",
         noRelapse: Int = 0,
         oneRelapse: Int = 0,
         twoRelapse: Int = 0,
         threeRelapse: Int = 0,
         fourRelapse: Int = 0,
         fiveRelapse: Int = 0,
         sixRelapse: Int = 0)
    {
        self.id = id
        self.title = title
        self.participants = participants
        self.challengers = challengers
        self.failedParticipants = failedParticipants
        self.description = description
        startDate = Challenge.dateFromString(startDateString) ?? Date()
        endDate = Challenge.dateFromString(endDateString) ?? Date()
        self.length = length
        self.currentStatus = currentStatus
        self.noRelapse = noRelapse
        self.oneRelapse = oneRelapse
        self.twoRelapse = twoRelapse
        self.threeRelapse = threeRelapse
        self.fourRelapse = fourRelapse
        self.fiveRelapse = fiveRelapse
        self.sixRelapse = sixRelapse
    }

    enum CodingKeys: String, CodingKey {
        case id, title, participants, failedParticipants, description,
             startDate, endDate, length, currentStatus, challengers,
             noRelapse, oneRelapse, twoRelapse, threeRelapse,
             fourRelapse, fiveRelapse, sixRelapse
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        participants = try container.decode(Int.self, forKey: .participants)
        challengers = try container.decode(Int.self, forKey: .challengers)
        failedParticipants = try container.decode(Int.self, forKey: .failedParticipants)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""

        let startDateString = try container.decode(String.self, forKey: .startDate)
        startDate = Challenge.dateFromString(startDateString) ?? Date()

        let endDateString = try container.decode(String.self, forKey: .endDate)
        endDate = Challenge.dateFromString(endDateString) ?? Date()

        length = try container.decode(Int.self, forKey: .length)
        currentStatus = try container.decode(String.self, forKey: .currentStatus)
        noRelapse = try container.decodeIfPresent(Int.self, forKey: .noRelapse) ?? 0
        oneRelapse = try container.decodeIfPresent(Int.self, forKey: .oneRelapse) ?? 0
        twoRelapse = try container.decodeIfPresent(Int.self, forKey: .twoRelapse) ?? 0
        threeRelapse = try container.decodeIfPresent(Int.self, forKey: .threeRelapse) ?? 0
        fourRelapse = try container.decodeIfPresent(Int.self, forKey: .fourRelapse) ?? 0
        fiveRelapse = try container.decodeIfPresent(Int.self, forKey: .fiveRelapse) ?? 0
        sixRelapse = try container.decodeIfPresent(Int.self, forKey: .sixRelapse) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(participants, forKey: .participants)
        try container.encode(challengers, forKey: .challengers)
        try container.encode(failedParticipants, forKey: .failedParticipants)
        try container.encode(description, forKey: .description)
        try container.encode(Challenge.stringFromDate(startDate), forKey: .startDate)
        try container.encode(Challenge.stringFromDate(endDate), forKey: .endDate)
        try container.encode(length, forKey: .length)
        try container.encode(currentStatus, forKey: .currentStatus)
        try container.encode(noRelapse, forKey: .noRelapse)
        try container.encode(oneRelapse, forKey: .oneRelapse)
        try container.encode(twoRelapse, forKey: .twoRelapse)
        try container.encode(threeRelapse, forKey: .threeRelapse)
        try container.encode(fourRelapse, forKey: .fourRelapse)
        try container.encode(fiveRelapse, forKey: .fiveRelapse)
        try container.encode(sixRelapse, forKey: .sixRelapse)
    }

    func encodeToDictionary() -> [String: Any]? {
        return [
            "id": id,
            "title": title,
            "participants": participants,
            "challengers": challengers,
            "failedParticipants": failedParticipants,
            "description": description,
            "startDate": Challenge.stringFromDate(startDate),
            "endDate": Challenge.stringFromDate(endDate),
            "length": length,
            "currentStatus": currentStatus,
            "noRelapse": noRelapse,
            "oneRelapse": oneRelapse,
            "twoRelapse": twoRelapse,
            "threeRelapse": threeRelapse,
            "fourRelapse": fourRelapse,
            "fiveRelapse": fiveRelapse,
            "sixRelapse": sixRelapse,
        ]
    }

    static func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString)
    }

    static func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    static var noNutNovember: Challenge {
        return Challenge(
            id: "No Nut November",
            title: "No Nut November",
            participants: 73,
            challengers: 21093,
            failedParticipants: 2372,
            description: "One of the hardest challenges to known to man. During these 30 days millions of boys across the globe take journey to become real men.If you've been looking for a way to test your willpower, boost your mental clarity, and regain control, this is for you. Want to go the extra mile? Track your progress daily and log your reflections in the app. You'll be surprised by how much you can achieve when you dedicate a month to a healthier, happier you.",
            startDateString: "Nov 1, 2024 12:00 AM",
            endDateString: "Nov 30, 2024 11:59 PM",
            length: 30,
            noRelapse: 2373,
            oneRelapse: 2373,
            twoRelapse: 4373,
            threeRelapse: 3813,
            fourRelapse: 1321,
            fiveRelapse: 1573,
            sixRelapse: 12813
        )
    }
    
    
    static var winterArc: Challenge {
        return Challenge(
            id: "Winter Arc Challenge",
            title: "Winter Arc Challenge",
            participants: 22093,
            challengers: 22093,
            failedParticipants: 0,
            description: "Prepare for the new year and embrace this winter. Transmute your sexual energy and make 2025 the best year of your life.",
            startDateString: "Dec 15, 2024 12:00 AM",
            endDateString: "Feb 28, 2025 11:59 PM",
            length: 60,
            noRelapse: 6046,
            oneRelapse: 2418,
            twoRelapse: 1814,
            threeRelapse: 967,
            fourRelapse: 483,
            fiveRelapse: 242,
            sixRelapse: 42
        )
    }
}
