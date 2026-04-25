//
//  HabitsView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
struct HabitsView: View {
    @State private var habits: [Habit] = []
    @State var sheetIsPresented = false
    @State private var logVM = HabitLogViewModel()
    @State var reload = false
    @Binding var selectedSection: AppSection
    @State private var hasLoaded = false
    @State private var isLoading = false
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment:.leading) {
                    Text("Habits")
                        .font(.title)
                        .bold()
                        .padding(.horizontal,10)
                    List(habits) { habit in
                        NavigationLink {
                            HabitDetailView(habit: habit, reload: $reload)
                        } label : {
                            HStack {
                                Image(systemName: habit.type.icon)
                                    .font(.title3)
                                    .foregroundStyle(habit.type.color)
                                    .frame(width: 38, height: 38)
                                    .background(habit.type.color.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.trailing, 6)
                                VStack(alignment: .leading) {
                                    Text(habit.type.displayName)
                                        .font(.headline)
                                        .bold()
                                    Text(progressText(for: habit))
                                        .font(.subheadline)
                                        .foregroundStyle(.black.opacity(0.5))
                                }
                                Spacer()
                                VStack {
                                    Spacer()
                                    ZStack {
                                        Image(systemName: "flame.fill")
                                            .foregroundStyle(.orange)
                                            .font(.title)
                                        Image(systemName: "flame")
                                            .foregroundStyle(.orange)
                                            .font(.title)
                                        Circle()
                                            .foregroundStyle(.orange)
                                            .frame(width: 13, height: 13)
                                            .offset(y:6)
                                        if let habitId = habit.id, let logs = logVM.logsByHabit[habitId] {
                                            Text("\(StreakCalculator.dailyStreak(logs: logs, targetCount: habit.targetCount))")
                                                .font(.footnote)
                                                .bold()
                                                .foregroundStyle(.white)
                                                .offset(y:3)
                                        }
                                        
                                    }
                                }
                                .padding(.trailing,10)
                            }
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        .background(.cardcolor)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.bottom, 10)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                guard let habitId = habit.id else { return }
                                
                                habits.removeAll { $0.id == habitId }
                                logVM.logsByHabit.removeValue(forKey: habitId)
                                
                                Task {
                                    let success = await HabitViewModel.deleteHabitAndLogs(habit: habit)
                                    if success {
                                        reload.toggle()
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.lightbackground)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("New", systemImage: "plus") {
                            sheetIsPresented.toggle()
                        }
                        .tint(.primarycolor)
                    }
                }
                .sheet(isPresented: $sheetIsPresented) {
                    NavigationStack {
                        HabitEditView(habit: Habit(), reload:$reload)
                    }
                }
                .onChange(of: reload) { oldValue, newValue in
                    Task {
                        await loadData()
                    }
                    
                }
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(4)
                        .tint(.primarycolor)
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.lightbackground)
        .task(id: selectedSection) {
            guard selectedSection == .habits else { return }
            guard !hasLoaded else { return }
            hasLoaded = true
            await loadData()
        }
        
    }
    
    private func progressText(for habit: Habit) -> String {
        let period = habit.period.rawValue.lowercased()
        guard let habitId = habit.id,
              let logs = logVM.logsByHabit[habitId] else {
            return "0/\(habit.targetCount) completed \(period == "day" ? "today" : "this \(period.capitalized)")"
        }

        let progress = HabitProgressCalculator.progress(for: habit, logs: logs)
        if progress.completedCount >= progress.targetCount {
            return "Completed \(period == "day" ? "today" : "this \(period)")"
        }
        return "\(progress.completedCount)/\(progress.targetCount) completed \(period == "day" ? "today" : "this \(period)")"
    }
    
    private func loadData() async {
        isLoading = true
        habits = await HabitViewModel.getHabits()
        await logVM.loadLogs(for: habits)
        isLoading = false
    }
}

