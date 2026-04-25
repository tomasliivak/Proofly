//
//  LogView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import SwiftUI

struct LogView: View {
    @State private var showCamera = false
    @State private var habits: [Habit] = []
    @State private var logVM = HabitLogViewModel()
    @Binding var selectedSection: AppSection
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text("Quick Action")
                    .foregroundStyle(.primarycolor)
                    .bold()
                    .font(.title3)
                Text("Capture a Habit")
                    .font(.title)
                    .bold()
                Text("Log your daily wins with a quick picture")
                    .foregroundStyle(.black.opacity(0.7))
                Button {
                    showCamera.toggle()
                } label: {
                    HStack {
                        Image(systemName: "camera")
                        Text("Capture to log")
                    }
                    .bold()
                    .frame(maxWidth: .infinity,minHeight: 40)
                }
                .buttonStyle(.glassProminent)
                .tint(.primarycolor)
                .padding(.horizontal, 10)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(.cardcolor)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.vertical, 10)
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            HStack {
                Text("Today's Habits")
                    .font(.custom("Inter", size: 20))
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    selectedSection = .habits
                } label: {
                    Text("View All")
                        .foregroundStyle(.primarycolor)
                        .bold()
                }
            }
            VStack {
                ForEach(habits.prefix(3)) { habit in // NEED TO ADD LOADING SCREEN
                    HStack {
                        Image(systemName: habit.type.icon)
                            .font(.title3)
                            .foregroundStyle(habit.type.color)
                            .frame(width: 38, height: 38)
                            .background(habit.type.color.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.trailing, 6)
                        if let habitId = habit.id, let logs = logVM.logsByHabit[habitId]{
                            let progress = HabitProgressCalculator.progress(for: habit, logs: logs)
                            VStack(alignment: .leading){
                                Text(habit.type.displayName)
                                    .font(.headline)
                                    .bold()
                                Text("\(progress.completedCount)/\(progress.targetCount) Logs Completed")
                                    .font(.subheadline)
                                    .foregroundStyle(.black.opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: progress.isComplete ? "checkmark.circle.fill" : "checkmark.circle")
                                .foregroundStyle(progress.isComplete ? .primarycolor.opacity(0.7) : .gray.opacity(0.3))
                                .font(.title)
                        }
                        
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                    .background(.cardcolor)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                    .padding(.top, 10)
                }
            }
            .padding(.horizontal, 5)
            HStack(spacing: 12) {
                VStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.title)
                    Text("Current Streak")
                        .foregroundStyle(.black.opacity(0.7))
                        .frame(maxWidth: .infinity)
                    Text("\(longestDailyStreak()) Day\(longestDailyStreak() == 1 ? "" : "s")")
                        .bold()
                        .font(.title2)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .padding(.horizontal, 15)
                .background(.cardcolor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.top, 10)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                VStack {
                    ZStack {
                        Circle()
                            .stroke(.lightbackground, lineWidth: 7)
                        Circle()
                            .trim(from:0, to:allStreakProgress())
                            .stroke(
                                .primarycolor,
                                style: StrokeStyle(lineWidth: 7, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        VStack{
                            Text("\(Int(allStreakProgress() * 100))%")
                                .font(.title3)
                                .bold()
                            Text("Completed")
                                .font(.footnote)
                                .foregroundStyle(.black.opacity(0.7))
                        }
                    }.frame(width: 100, height: 100)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .padding(.horizontal, 15)
                .background(.cardcolor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.top, 10)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            }
            Spacer()
            
        }
        .padding(.horizontal, 15)
        .background(.lightbackground)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fullScreenCover(isPresented: $showCamera) {
            NavigationStack {
                CameraView()
            }
        }
        .onChange(of: showCamera, { oldValue, newValue in
            Task {
                await logVM.loadLogs(for: habits)
            }
        })
        .task {
            habits = await HabitViewModel.getHabits()
            await logVM.loadLogs(for: habits)
        }
        
    }
    
    func longestDailyStreak() -> Int {
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
    
    func allStreakProgress() -> Double {
        var completed = 0
        var target = 0
        if habits.count == 0 {
            return 0.0
        }
        for habit in habits {
            if let habitId = habit.id, let logs = logVM.logsByHabit[habitId]{
                let returned = HabitProgressCalculator.progress(for: habit, logs: logs)
                if returned.completedCount > returned.targetCount {
                    completed += returned.targetCount
                    target += returned.targetCount
                }
                else {
                    completed += returned.completedCount
                    target += returned.targetCount
                }
            }
        }
        guard target > 0 else {
            return 0.0
        }
        var progress = Double(completed) / Double(target)
        if progress > 1 {
            progress = 1.0
        }
        
        return progress
    }
}

