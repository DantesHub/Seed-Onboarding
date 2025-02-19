//
//  FirebaseService.swift
//  Resolved
//
//  Created by Dante Kim on 9/30/24.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

enum FirebaseCollection: String {
    case dailySummaries = "daily_summaries"
    case challenges = "challenges"
    case users = "users"
    case intervals = "intervals"
}

struct FirebaseService {
    static var shared = FirebaseService()
    static let db = Firestore.firestore()
    static let errorDomain = Bundle.main.bundleIdentifier ?? "app.nafs" + ".FirebaseService"

    enum ErrorCode: Int {
        case authenticationError
        case databaseError
        case storageError
        case unknownError
    }

    static func isLoggedIn() -> Bool {
        if let _ = Auth.auth().currentUser {
            return true
        } else {
            return false
        }
    }

    func signOut() throws {
        if let currUser = Auth.auth().currentUser {
            try Auth.auth().signOut()
        }
    }
    
    

    static func updateIsProStatus(userId _: String, isPro _: Bool) {
        let db = Firestore.firestore()
        let invitesColectionRef = db.collection("invites")
    }

    // MARK: - Firestore database

    func batchSave(documents: [(collection: FirebaseCollection, data: [String: Any])]) async throws {
        let batch = Firestore.firestore().batch()

        for doc in documents {
            if let id = doc.data["id"] as? String {
                let ref = Firestore.firestore().collection(doc.collection.rawValue).document(id)
                batch.setData(doc.data, forDocument: ref)
            } else {
                throw NSError(domain: FirebaseService.errorDomain, code: FirebaseService.ErrorCode.databaseError.rawValue, userInfo: [NSLocalizedDescriptionKey: "Document data is missing 'id' field"])
            }
        }

        try await batch.commit()
    }

    static func getDocumentsWhere<T: Codable>(collection: String, field: String, isEqualTo: Any) async throws -> [T] {
        let query = db.collection(collection).whereField(field, isEqualTo: isEqualTo)
        let querySnapshot = try await query.getDocuments()

        return try querySnapshot.documents.compactMap { document in
            let jsonData = try JSONSerialization.data(withJSONObject: document.data())
            return try JSONDecoder().decode(T.self, from: jsonData)
        }
    }

    // MARK: - Getter Methods

    func getDocument<T: Codable>(collection: FirebaseCollection, documentId: String) async throws -> T {
        let docRef = FirebaseService.db.collection(collection.rawValue).document(documentId)

        do {
            let snapshot = try await docRef.getDocument()
            guard snapshot.exists else {
                throw NSError(domain: FirebaseService.errorDomain,
                              code: 404,
                              userInfo: [NSLocalizedDescriptionKey: "Document not found in collection '\(collection)' with ID '\(documentId)'"])
            }

            guard let data = snapshot.data() else {
                throw NSError(domain: FirebaseService.errorDomain,
                              code: 404,
                              userInfo: [NSLocalizedDescriptionKey: "Document not found in collection '\(collection)' with ID '\(documentId)'"])
            }

            let jsonData = try JSONSerialization.data(withJSONObject: data)

            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: jsonData)
                return decodedObject
            } catch {
                print("Decoding error: \(error)")
                print("JSON data: \(String(data: jsonData, encoding: .utf8) ?? "Unable to convert data to string")")
                throw NSError(domain: FirebaseService.errorDomain,
                              code: 400,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to decode document data for type \(T.self). Error: \(error.localizedDescription)",
                                         NSDebugDescriptionErrorKey: "Raw data: \(data)"])
            }
        } catch {
            print("Firestore error: \(error)")
            let errorCode = FirebaseService.isLoggedIn() ? 400 : 401
            throw NSError(domain: FirebaseService.errorDomain,
                          code: errorCode,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to fetch document from Firestore. Collection: '\(collection)', ID: '\(documentId)'. Error: \(error.localizedDescription)"])
        }
    }

    func addDocument(_ object: FBObject, collection: String, completion: @escaping (String?) -> Void) {
        if let dict = object.encodeToDictionary() {
            let id = dict["id"] as! String
            let ref = FirebaseService.db.collection(collection).document(id)
            ref.setData(dict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion(nil)
                } else {
                    print("Document added with ID: \(ref.documentID)")
                    completion(ref.documentID)
                }
            }

        } else {
            print("error here")
            completion(nil)
        }
    }
    
    func updateField(collection: String, documentId: String, field: String, value: Any) async throws {
        let docRef = FirebaseService.db.collection(collection).document(documentId)
        
        do {
            try await docRef.updateData([field: value])
        } catch {
           
        }
    }

    func updateDocument(collection: FirebaseCollection, object: FBObject) async throws {
        let documentCollection = FirebaseService.db.collection(collection.rawValue)

        return try await withCheckedThrowingContinuation { continuation in
            guard let newData = object.encodeToDictionary(), let id = newData["id"] as? String else {
                continuation.resume(throwing: NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode object to dictionary or missing id"]))
                return
            }

            let docRef = documentCollection.document(id)
            docRef.getDocument { document, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                if let document = document, document.exists {
                    // Document exists, update it with merge
                    docRef.setData(newData, merge: true) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            print("Document successfully updated with new fields")
                            continuation.resume(returning: ())
                        }
                    }
                } else {
                    // Document doesn't exist, create it
                    docRef.setData(newData) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            print("Document successfully created")
                            continuation.resume(returning: ())
                        }
                    }
                }
            }
        }
    }

    static func createUser(user: User?, completion: @escaping (String?) -> Void) {
        guard let user else { return }

        if let userDict = user.encodeToDictionary() {
            let id = userDict["id"] as! String
            let ref = FirebaseService.db.collection("users").document(id)
            ref.setData(userDict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion(nil)
                } else {
                    print("Document added with ID: \(ref.documentID)")
                    //                    UserDefaults.standard.setValue(id, forKey: "userId")
                    completion(ref.documentID)
                }
            }
        }
    }

    static func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    func deleteDocument(collection: FirebaseCollection, documentId: String) async throws {
        let documentRef = FirebaseService.db.collection(collection.rawValue).document(documentId)
        try await documentRef.delete()
        print("Document successfully deleted")
    }

    static func getUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard FirebaseService.isUserLoggedIn() else {
            completion(.failure(NSError(domain: FirebaseService.errorDomain, code: FirebaseService.ErrorCode.authenticationError.rawValue, userInfo: [NSLocalizedDescriptionKey: "User is not logged in."])))
            return
        }

        if let token = UserDefaults.standard.string(forKey: Constants.token) {
            let userCollection = FirebaseService.db.collection("users")
            userCollection.whereField("appleToken", isEqualTo: token).getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                // Assuming there's only one user with this phone number
                if let document = querySnapshot?.documents.first {
                    do {
                        var documentData = document.data()
                        let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])

                        let retUser = try JSONDecoder().decode(User.self, from: jsonData)

                        completion(.success(retUser))
                    } catch let decodeError {
                        completion(.failure(decodeError))
                    }
                } else {
                    // Handle the case where no documents are found
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found with that phone number"])))
                }
            }
        }
    }

    static func checkIfUserExists(token: String) async throws -> Bool {
        let db = Firestore.firestore()
        let usersCollectionRef = db.collection("users")

        do {
            let querySnapshot = try await usersCollectionRef.whereField("appleToken", isEqualTo: token).getDocuments()
            return !querySnapshot.isEmpty
        } catch {
            print("checking if user be existing", error.localizedDescription)
            return false
        }
    }

    static func signOut() throws {
        try Auth.auth().signOut()
    }

    static func getIntervals(for userId: String, completion: @escaping (Result<[SoberInterval], Error>) -> Void) {
        guard FirebaseService.isUserLoggedIn() else {
            completion(.failure(NSError(domain: FirebaseService.errorDomain, code: FirebaseService.ErrorCode.authenticationError.rawValue, userInfo: [NSLocalizedDescriptionKey: "User is not logged in."])))
            return
        }

        let intervalsCollection = FirebaseService.db.collection("intervals")
        intervalsCollection.whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            var intervals: [SoberInterval] = []

            for document in querySnapshot?.documents ?? [] {
                do {
                    let documentData = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: documentData, options: [])
                    let interval = try JSONDecoder().decode(SoberInterval.self, from: jsonData)
                    intervals.append(interval)
                } catch let decodeError {
                    completion(.failure(decodeError))
                    return
                }
            }

            completion(.success(intervals))
        }
    }
}
