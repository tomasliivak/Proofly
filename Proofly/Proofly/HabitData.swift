//
//  HabitData.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import Foundation
import SwiftUI

struct LocalHabit: Identifiable {
    let id = UUID()
    let name: String
    let keywords: [String]
}

enum HabitType: String, CaseIterable, Identifiable, Codable {
    case study
    case read
    case drinkWater
    case workout
    case eatFruit

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .study: return "Study"
        case .read: return "Read"
        case .drinkWater: return "Drink Water"
        case .workout: return "Workout"
        case .eatFruit: return "Eat Fruit"
        }
    }
    
    var localHabit: LocalHabit {
        switch self {
        case .study: return HabitData.habits[0]
        case .read: return HabitData.habits[1]
        case .drinkWater: return HabitData.habits[2]
        case .workout: return HabitData.habits[3]
        case .eatFruit: return HabitData.habits[4] // this is pretty stupid I think I should just get rid of HabitData at some point
        }
    }
    
    var icon: String {
        switch self {
        case .study: return "pencil"
        case .read: return "book.fill"
        case .drinkWater: return "drop.fill"
        case .workout: return "figure.run"
        case .eatFruit: return "apple.logo"
        }
    }
    
    var color: Color {
        switch self {
        case .study: return .blue
        case .read: return .purple
        case .drinkWater: return .cyan
        case .workout: return .orange
        case .eatFruit: return .green
        }
    }
    
    var description: String {
            switch self {
            case .study: return "Log study sessions with a quick photo."
            case .read: return "Track reading progress with proof."
            case .drinkWater: return "Stay consistent with hydration."
            case .workout: return "Capture workouts and build momentum."
            case .eatFruit: return "Keep your nutrition habits visible."
            }
        }
}

struct HabitData { // prolly should change
    static let habits: [LocalHabit] = [
        LocalHabit(
            name: "Study",
            keywords: ["laptop", "computer", "notebook", "paper", "pencil", "desk", "office supplies"]
        ),
        LocalHabit(
            name: "Read",
            keywords: ["book", "textbook", "paper", "pages", "office supplies", "paper product"]
        ),
        LocalHabit(
            name: "Drink Water",
            keywords: ["water", "bottle", "drink", "cylinder", "water bottle", "cup"]
        ),
        LocalHabit(
            name: "Workout",
            keywords: ["dumbbell", "barbell", "gym", "fitness", "yoga mat","shoes", "sneakers", "shoe"]
        ),
        LocalHabit(
            name: "Eat Fruit",
            keywords: ["banana", "apple", "fruit", "produce", "food"]
        )
    ]
}

struct HabitMatcher {
    static func match(labels: [String], to habit: LocalHabit) -> Bool {
        let lowercasedLabels = labels.map { $0.lowercased() }
        return lowercasedLabels.contains { label in
            habit.keywords.contains { keyword in
                label.contains(keyword)
            }
        }
    }
}
