//
//  HabitLog.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/23/26.
//

import Foundation
import FirebaseFirestore

struct HabitLog: Codable, Identifiable {
    @DocumentID var id: String?
    var habitId: String
    var createdAt: Date
    var photoUrl: String
    var storagePath: String
}
