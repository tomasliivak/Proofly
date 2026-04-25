//
//  HabitViewModel.swift
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
class HabitViewModel {

    static func saveHabit(habit: Habit) async -> String? {
        let db = Firestore.firestore()

        guard let uid = Auth.auth().currentUser?.uid else {
            print("😡 ERROR: No logged in user found.")
            return nil
        }

        let habitsRef = db.collection("users").document(uid).collection("habits")

        if let id = habit.id { // if true, the habit exists already
            do {
                try habitsRef.document(id).setData(from: habit)
                print("😎 Habit updated successfully!")
                return id
            } catch {
                print("😡 ERROR: Could not update habit. \(error.localizedDescription)")
                return id
            }
        } else { // the habit does not exist, so create it
            do {
                let docRef = try habitsRef.addDocument(from: habit)
                print("🔥 Habit added successfully!")
                return docRef.documentID
            } catch {
                print("😡 ERROR: Could not create new habit. \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func getHabits() async -> [Habit] {
        let db = Firestore.firestore()

        guard let uid = Auth.auth().currentUser?.uid else {
            print("😡 ERROR: No logged in user found.")
            return []
        }

        do {
            let snapshot = try await db
                .collection("users")
                .document(uid)
                .collection("habits")
                .getDocuments()

            let habits = snapshot.documents.compactMap { doc in
                try? doc.data(as: Habit.self)
            }

            print("😎 Habits fetched: \(habits.count)")
            return habits

        } catch {
            print("😡 ERROR: Could not fetch habits. \(error.localizedDescription)")
            return []
        }
    }
    
    static func deleteHabitAndLogs(habit: Habit) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return false
        }

        guard let habitId = habit.id else {
            print("Habit has no id")
            return false
        }

        let db = Firestore.firestore()
        let storage = Storage.storage().reference()

        let habitRef = db.collection("users")
            .document(uid)
            .collection("habits")
            .document(habitId)

        do {
            let logsSnapshot = try await habitRef.collection("logs").getDocuments()

            for doc in logsSnapshot.documents {
                let log = try? doc.data(as: HabitLog.self)

                if let storagePath = log?.storagePath,
                   !storagePath.isEmpty {
                    do {
                        try await storage.child(storagePath).delete()
                        print("Deleted image at \(storagePath)")
                    } catch {
                        print("Could not delete image: \(error.localizedDescription)")
                    }
                }

                try await doc.reference.delete()
            }

            try await habitRef.delete()

            print("Deleted habit, logs, and images")
            return true

        } catch {
            print("Error deleting habit: \(error.localizedDescription)")
            return false
        }
    }
    
}
