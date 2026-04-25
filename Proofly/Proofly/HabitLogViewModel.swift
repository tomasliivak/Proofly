//
//  HabitLogViewModel.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/23/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SwiftUI

@Observable
class HabitLogViewModel {
    var logsByHabit: [String: [HabitLog]] = [:]
    
    func loadLogs(for habits: [Habit]) async {
        for habit in habits {
            guard let id = habit.id else { continue }
            logsByHabit[id] = await Self.getLogs(for: id)
        }
    }
    
    static func logHabitCompletion(habitId: String, log: HabitLog, data: Data) async -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("😡 ERROR: No logged in user found.")
            return nil
        }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let photoId = UUID().uuidString
        let path = "users/\(uid)/habits/\(habitId)/logs/\(photoId).jpg"
        
        
        let db = Firestore.firestore()
        
        let logsRef = db.collection("users").document(uid).collection("habits").document(habitId).collection("logs")
        do {
            let storageref = storage.child(path)
            let returnedMetaData = try await storageref.putDataAsync(data, metadata: metadata)
            print("SAVED! \(returnedMetaData)")
            guard let url = try? await storageref.downloadURL() else {
                print("Could not get download url")
                return nil
            }
            var updatedLog = log
            updatedLog.photoUrl = url.absoluteString
            updatedLog.storagePath = path
            print(url.absoluteString)
            do {
                let docRef = try logsRef.addDocument(from: updatedLog)
                print("✅ Habit completion logged successfully!")
                return docRef.documentID
            } catch {
                print("😡 ERROR: Could not log habit completion. \(error.localizedDescription)")
                return nil
            }
        } catch {
            print("ERROR: saving photo to Storage \(error.localizedDescription)")
        }
        return nil
    }
    
    static func getLogs(for habitId: String) async -> [HabitLog] {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("😡 ERROR: No logged in user found.")
            return []
        }
        
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("users")
                .document(uid)
                .collection("habits")
                .document(habitId)
                .collection("logs")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let logs = snapshot.documents.compactMap { document in
                try? document.data(as: HabitLog.self)
            }
            
            print("✅ Logs fetched: \(logs.count)")
            return logs
            
        } catch {
            print("😡 ERROR: Could not fetch logs. \(error.localizedDescription)")
            return []
        }
    }
    
}
