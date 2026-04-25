//
//  Habit.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/23/26.
//

import Foundation
import FirebaseFirestore
enum HabitPeriod: String, Codable {
    case day
    case week
}

struct Habit: Codable, Identifiable {
    @DocumentID var id: String?
    var type = HabitType.study
    var isActive = false
    var createdAt = Date()
    var updatedAt = Date()
    var targetCount = 1
    var streakCount = 0 // ends up not being used
    var period = HabitPeriod.day
}
