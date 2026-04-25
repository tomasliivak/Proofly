//
//  ProfileView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/23/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var logVM = HabitLogViewModel()
    @State private var hasLoaded = false
    @State private var isLoading = false
    @State private var habits: [Habit] = []
    @State private var totalCompleted = 0
    @State private var totalUncompleted = 0
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Your Stats")
                    .font(.title)
                    .bold()
                Spacer()
                Button("Sign Out") {
                    do {
                        try Auth.auth().signOut()
                        print("🪵➡️ Log out successful!")
                        isLoggedIn = false
                    } catch {
                        print("😡 ERROR: Could not sign out!")
                    }
                }
                .font(.title)
                .buttonStyle(.glassProminent)
                .tint(.primarycolor)
                .foregroundStyle(.white)
            }
            HStack {
                VStack(alignment: .leading) {
                    HStack{
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.title)
                        Text("Current Streak: ")
                        Text("\(longestDailyStreak())")
                            .bold()
                    }
                    .padding(.bottom)
                    HStack(alignment: .bottom) {
                        Image(systemName: "camera.fill")
                        Text("Total Logs: ")
                        Text("\(logCount())")
                            .bold()
                    }
                    .padding(.bottom)
                    HStack(alignment: .bottom) {
                        Image(systemName: "figure.run")
                            .foregroundStyle(.green)
                        Text("Completed Daily Habits: ")
                        Text("\(totalCompleted)")
                            .bold()
                    }
                    .padding(.bottom)
                    HStack(alignment: .bottom) {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundStyle(.mint)
                        Text("Completation Rate")
                        Text("\(totalUncompleted != 0 ? Int(Double(totalCompleted)/Double(totalUncompleted+totalCompleted)*100) : 0)%")
                            .bold()
                    }
                }
                Spacer()
            }
            .padding(18)
            .background(.cardcolor)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            Spacer()
        }
        .padding(.horizontal)
        .task {
            await loadData()
            allCompletionStats()
        }
        
        }
    
    func longestDailyStreak() -> Int { // lowkey should refactor this into a seperate file
        var longest = 0
        for habit in habits {
            if let habitId = habit.id, let logs = logVM.logsByHabit[habitId]{
                let streak = StreakCalculator.dailyStreak(logs: logs, targetCount: habit.targetCount) // is targetCount redundant?
                if streak > longest {
                    longest = streak
                }
            }
        }
        return longest
    }
    func logCount() -> Int {
        var count = 0
        for habit in habits {
            if let habitId = habit.id, let logs = logVM.logsByHabit[habitId]{
                count += logs.count
            }
        }
        return count
    }
    private func loadData() async {
        isLoading = true
        habits = await HabitViewModel.getHabits()
        await logVM.loadLogs(for: habits)
        isLoading = false
    }
    
    func completionStatsFull(
        logs: [HabitLog],
        targetCount: Int,
        startDate: Date,
        endDate: Date,
        calendar: Calendar = .current
    ) -> (completedDays: Int, uncompletedDays: Int) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = calendar

        print("----- DEBUG START -----")
        print("Total logs:", logs.count)
        print("Target count:", targetCount)
        print("Start date:", startDate)
        print("End date:", endDate)

        for log in logs {
            print("Log createdAt:", log.createdAt)
        }

        let grouped = Dictionary(grouping: logs) { log in
            formatter.string(from: log.createdAt)
        }

        print("Grouped keys:", grouped.keys)

        var completedDays = 0
        var uncompletedDays = 0

        var current = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        print("Normalized start:", current)
        print("Normalized end:", end)

        while current <= end {
            let key = formatter.string(from: current)
            let count = grouped[key]?.count ?? 0

            print("Checking date:", key, "| count:", count)

            if count >= targetCount {
                completedDays += 1
            } else {
                uncompletedDays += 1
            }

            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        print("Completed days:", completedDays)
        print("Uncompleted days:", uncompletedDays)
        print("----- DEBUG END -----")

        return (completedDays, uncompletedDays)
    }
    
    func allCompletionStats() {
        
        var completed = 0
        var uncompleted = 0
        for habit in habits {
            
            if let habitId = habit.id, let logs = logVM.logsByHabit[habitId] {
                let (cReturned, uReturned) = completionStatsFull(logs: logs, targetCount: habit.targetCount, startDate: habit.createdAt, endDate: Date())
                print(cReturned)
                print(uReturned)
                completed += cReturned
                uncompleted += uReturned
            }
        }
        totalCompleted = completed
        totalUncompleted = uncompleted
    }
}



