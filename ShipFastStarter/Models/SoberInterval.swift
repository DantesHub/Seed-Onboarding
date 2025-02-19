//
//  SoberInterval.swift
//  NoFap
//
//  Created by Dante Kim on 7/10/24.
//

import Foundation
import SwiftData

@Model
class SoberInterval: Codable, Identifiable, FBObject {
    @Attribute(.unique) var id: String = UUID().uuidString
    var userId: String = ""
    var startDate: String = Date().toString()
    var endDate: String = ""
    var seed: String = ""
    var seedTXP: Double = 0.0
    var lastCheckInDate: String = Date().toString()
    var reasonsForLapsing: [String] = []
    var lapseNotes: [String: String] = [:]
    var motivationalNotes: [String: String] = [:]
    var thoughtNotes: [String: String] = [:]

    init(id: String = UUID().uuidString,
         userId: String = "",
         startDate: String = Date().toString(),
         endDate: String = "",
         seed: String = "",
         seedTXP: Double = 0.0,
         lastCheckInDate: String = Date().toString(),
         reasonsForLapsing: [String] = [],
         lapseNotes: [String: String] = [:],
         motivationalNotes: [String: String] = [:],
         thoughtNotes: [String: String] = [:])
    {
        self.id = id
        self.userId = userId
        self.startDate = startDate
        self.endDate = endDate
        self.seed = seed
        self.seedTXP = seedTXP
        self.lastCheckInDate = lastCheckInDate
        self.reasonsForLapsing = reasonsForLapsing
        self.lapseNotes = lapseNotes
        self.motivationalNotes = motivationalNotes
        self.thoughtNotes = thoughtNotes
    }

    var formattedStartDate: Date {
        return Date.fromString(startDate) ?? Date()
    }

    static func createSoberInterval() -> SoberInterval { // Updated this function
        let id = UserDefaults.standard.string(forKey: "userId") ?? ""
        let newInterval = SoberInterval(id: UUID().uuidString, userId: id, startDate: Date().toString(), endDate: "", seed: Orb.originalSeed.name(), seedTXP: 0, lastCheckInDate: Date().toString(), reasonsForLapsing: [], lapseNotes: [:], motivationalNotes: [:], thoughtNotes: [:])
        return newInterval
    }

    func toString() -> String {
        return """
        User ID: \(userId)  // Added this line
        Started \(startDate)
        Ended \(endDate)
        reasons for relapsing: \(reasonsForLapsing)
        trigger notes: \(lapseNotes)
        future notes user wrote to himself: \(motivationalNotes)
        thought notes: \(thoughtNotes)
        """
    }

    // Encoding to dictionary
    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding SoberInterval to dictionary: \(error)")
            return nil
        }
    }

    // Decoding from dictionary
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId) // Added this line
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        seed = try container.decode(String.self, forKey: .seed)
        seedTXP = try container.decode(Double.self, forKey: .seedTXP)
        lastCheckInDate = try container.decode(String.self, forKey: .lastCheckInDate)
        reasonsForLapsing = try container.decode([String].self, forKey: .reasonsForLapsing)
        lapseNotes = try container.decode([String: String].self, forKey: .lapseNotes)
        motivationalNotes = try container.decode([String: String].self, forKey: .motivationalNotes)
        thoughtNotes = try container.decode([String: String].self, forKey: .thoughtNotes)
    }

    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId) // Added this line
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(seed, forKey: .seed)
        try container.encode(seedTXP, forKey: .seedTXP)
        try container.encode(lastCheckInDate, forKey: .lastCheckInDate)
        try container.encode(reasonsForLapsing, forKey: .reasonsForLapsing)
        try container.encode(lapseNotes, forKey: .lapseNotes)
        try container.encode(motivationalNotes, forKey: .motivationalNotes)
        try container.encode(thoughtNotes, forKey: .thoughtNotes)
    }

    enum CodingKeys: String, CodingKey {
        case id, userId, startDate, endDate, seed, seedTXP, lastCheckInDate, reasonsForLapsing, lapseNotes, motivationalNotes, thoughtNotes
    }
}

extension SoberInterval {
    static var schema: Schema {
        Schema(
            [
                SoberInterval.self,
            ],
            version: Schema.Version(1, 0, 0)
        )
    }
}

// import Foundation
// import SwiftData
//
// enum SchemaV1: VersionedSchema {
//    static var models: [any PersistentModel.Type] {
//        [SoberInterval.self]
//    }
//
//    static var versionIdentifier: Schema.Version {
//        Schema.Version(1, 0, 0)
//    }
//    @Model
//    final class SoberInterval: Identifiable {
//        var id: String
//        var startDate: String
//        var endDate: String
//        var seed: String
//        var seedTXP: Double
//
//        init(id: String, startDate: String, endDate: String, seed: String, seedTXP: Double) {
//            self.id = id
//            self.startDate = startDate
//            self.endDate = endDate
//            self.seed = seed
//            self.seedTXP = seedTXP
//        }
//    }
// }

// enum SchemaV2: VersionedSchema {
//    static var versionIdentifier: Schema.Version {
//        Schema.Version(2, 0, 0)
//    }
//    static var models: [any PersistentModel.Type] {
//        [SoberInterval.self]
//    }
//
//
//    @Model
//    final class SoberInterval: Identifiable {
//        var id: String
//        var startDate: String
//        var endDate: String
//        var seed: String
//        var seedTXP: Double
//        var lastCheckInDate: String
//        var lapseNotes: [String: String]
//        var motivationalNotes: [String: String]
//
//        init(id: String, startDate: String, endDate: String, seed: String, seedTXP: Double, lastCheckInDate: String) {
//            self.id = id
//            self.startDate = startDate
//            self.endDate = endDate
//            self.seed = seed
//            self.seedTXP = seedTXP
//            self.lastCheckInDate = lastCheckInDate
//        }
//    }
// }
//
//
// import SwiftData
//
// enum SoberIntervalMigrationPlan: SchemaMigrationPlan {
//    static var schemas: [any VersionedSchema.Type] {
//        [SchemaV1.self, SchemaV2.self]
//    }
//
//    static var stages: [MigrationStage] {
//        [migrateV1toV2]
//    }
//
//    static let migrateV1toV2 = MigrationStage.custom(
//        fromVersion: SchemaV1.self,
//        toVersion: SchemaV2.self,
//        willMigrate: { context in
//            let descriptor = FetchDescriptor<SchemaV1.SoberInterval>()
//            guard let oldIntervals = try? context.fetch(descriptor) else { return }
//
//            for oldInterval in oldIntervals {
//                // Create a new V2 SoberInterval
//                let newInterval = SchemaV2.SoberInterval(
//                    id: oldInterval.id,
//                    startDate: oldInterval.startDate,
//                    endDate: oldInterval.endDate,
//                    seed: oldInterval.seed,
//                    seedTXP: oldInterval.seedTXP,
//                    lastCheckInDate: oldInterval.startDate // Default to startDate
//                )
//
//                // Add the new interval to the context
//                context.insert(newInterval)
//
//                // Delete the old interval
//                context.delete(oldInterval)
//            }
//        },
//        didMigrate: nil
//    )
// }
