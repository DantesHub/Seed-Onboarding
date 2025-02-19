import Foundation
import SwiftData

struct UserMigrationPlan: SchemaMigrationPlan {
    // Define the schemas for each version
    static var schemas: [VersionedSchema.Type] = [
        UserSchemaV1.self,
        UserSchemaV2.self,
    ]

    // Define the migration stages
    static var stages: [MigrationStage] = [
        MigrationStage.custom(
            fromVersion: UserSchemaV1.self,
            toVersion: UserSchemaV2.self,
            willMigrate: { context in
                // Fetch old version users from UserSchemaV1
                let users = try? context.fetch(FetchDescriptor<UserSchemaV1.User>())

                // Perform any necessary pre-migration logic
                print("Migrating from UserSchemaV1 to UserSchemaV2")

                // Optionally perform changes on V1 users
                try? context.save() // Ensure V1 users are saved before the migration
            },
            didMigrate: { context in
                // Fetch new version users from UserSchemaV2
                let users = try? context.fetch(FetchDescriptor<UserSchemaV2.User>())

                // Ensure all users get a default value for the new `appleToken` property
                for user in users ?? [] {
                    user.appleToken = "" // Default value for newly added property
                }

                // Save the migrated context with V2 users
                try? context.save()
            }
        ),
    ]
}

enum UserSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [User.self]
    }

    @Model
    final class User {
        // Old version of User without `appleToken`
        var id: String = UUID().uuidString
        var joinDate: String
        var email: String
        var isPro: Bool
        var currentStreak: Int
        var currentOrb: String
        var name: String
        var religion: String
        var age: String
        var completedLessons: [Int]
        var minsSavedPerDay: Double
        var gender: String
        var userExercises: [String: String]
        var howOften: String
        var challenges: [String: String]

        // Define the init for this schema version
        init(joinDate: String, email: String, isPro: Bool, currentStreak: Int, currentOrb: String, name: String, religion: String, age: String, completedLessons: [Int], minsSavedPerDay: Double, gender: String, userExercises: [String: String], howOften: String, challenges: [String: String]) {
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
            self.howOften = howOften
            self.challenges = challenges
        }
    }
}

enum UserSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [User.self]
    }

    @Model
    final class User {
        // New version of User with `appleToken`
        var id: String = UUID().uuidString
        var joinDate: String
        var email: String
        var isPro: Bool
        var currentStreak: Int
        var currentOrb: String
        var name: String
        var religion: String
        var age: String
        var completedLessons: [Int]
        var minsSavedPerDay: Double
        var gender: String
        var userExercises: [String: String]
        var appleToken: String = "" // New field
        var howOften: String
        var challenges: [String: String]

        // Define the init for this schema version
        init(joinDate: String, email: String, isPro: Bool, currentStreak: Int, currentOrb: String, name: String, religion: String, age: String, completedLessons: [Int], minsSavedPerDay: Double, gender: String, userExercises: [String: String], appleToken: String, howOften: String, challenges: [String: String]) {
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
        }
    }
}
