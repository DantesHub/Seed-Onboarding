//
//  CheckInDay.swift
//  Resolved
//
//  Created by Dante Kim on 10/19/24.
//

import Foundation
import SwiftData

final class CheckInDay: Codable, Identifiable, FBObject {
    var id: String = UUID().uuidString
    var date: String = Date().toString()
    var failed: Int = 0
    var succeeded: Int = 0
    var totalCheckedIn: Int = 0
    var moods: [String: Int] = [:]

    init(id: String = UUID().uuidString,
         date: String = Date().toString(),
         failed: Int = 0,
         succeeded: Int = 0,
         totalCheckedIn: Int = 0,
         moods: [String: Int] = [:])
    {
        self.id = id
        self.date = date
        self.failed = failed
        self.succeeded = succeeded
        self.totalCheckedIn = totalCheckedIn
        self.moods = moods
    }

    static var exCheckInDay: CheckInDay {
        CheckInDay(id: Date().toString(format: "Oct 14, 2024"),
                   date: Date().toString(format: "Oct 14, 2024"),
                   failed: 0,
                   succeeded: 0,
                   totalCheckedIn: 0,
                   moods: ["😊": 0, "😐": 0, "😔": 0])
    }

    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding CheckInDay to dictionary: \(error)")
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, date, failed, succeeded, totalCheckedIn, moods
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(String.self, forKey: .date)
        failed = try container.decode(Int.self, forKey: .failed)
        succeeded = try container.decode(Int.self, forKey: .succeeded)
        totalCheckedIn = try container.decode(Int.self, forKey: .totalCheckedIn)
        moods = try container.decode([String: Int].self, forKey: .moods)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(failed, forKey: .failed)
        try container.encode(succeeded, forKey: .succeeded)
        try container.encode(totalCheckedIn, forKey: .totalCheckedIn)
        try container.encode(moods, forKey: .moods)
    }
}
