//
//  HabitProgressCalculations.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/23/26.
//

import Foundation

struct HabitProgress {
    let completedCount: Int
    let targetCount: Int
    let isComplete: Bool
}

struct HabitProgressCalculator {

    static func progress(for habit: Habit, logs: [HabitLog], date: Date = Date()) -> HabitProgress {
        
        let relevantLogs: [HabitLog]

        switch habit.period {
        case .day:
            relevantLogs = logs.filter {
                Calendar.current.isDate($0.createdAt, inSameDayAs: date)
            }

        case .week:
            relevantLogs = logs.filter {
                Calendar.current.isDate($0.createdAt, equalTo: date, toGranularity: .weekOfYear)
            }
        }

        let count = relevantLogs.count
        let isComplete = count >= habit.targetCount
        
        return HabitProgress(
            completedCount: count,
            targetCount: habit.targetCount,
            isComplete: isComplete
        )
    }
}

struct StreakCalculator {
    static func dailyStreak(logs: [HabitLog], targetCount: Int, today: Date = Date()) -> Int {
        let calendar = Calendar.current

        let groupedByDay = Dictionary(grouping: logs) { log in
            calendar.startOfDay(for: log.createdAt)
        }

        let todayStart = calendar.startOfDay(for: today)
        let todayCount = groupedByDay[todayStart]?.count ?? 0

        var currentDate = todayStart

        if todayCount < targetCount {
            currentDate = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        }

        var streak = 0

        while true {
            let count = groupedByDay[currentDate]?.count ?? 0

            if count >= targetCount {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }

        return streak
    }
}
