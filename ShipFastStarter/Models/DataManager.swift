//
//  DataManager.swift
//  Resolved
//
//  Created by Dante Kim on 7/12/24.
//

import Foundation
import SwiftData

struct DataManager {
    static var shared = DataManager()

    // Function to delete all data in a SwiftData managed context
    func deleteAllData(context: ModelContext) {
        do {
            try context.delete(model: User.self)
            try context.delete(model: SoberInterval.self)
        } catch {
            print("Failed to clear all Country and City data.")
        }
    }

    func deleteSession(_ object: SoberInterval, context: ModelContext) {
        context.delete(object)
        saveContext(context: context)
    }

    func saveContext(context: ModelContext) {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    func batchSaveIntervals(_ intervals: [SoberInterval], context: ModelContext) {
        do {
            try context.transaction {
                for interval in intervals {
                    context.insert(interval)
                }
                try context.save()
            }
            print("Batch save completed")
        } catch {
            print("Error during batch save: \(error)")
        }
    }
}
