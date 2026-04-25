//
//  HabitEditView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/23/26.
//

import SwiftUI

struct HabitEditView: View {
    @State var habit: Habit
    @Environment(\.dismiss) private var dismiss
    @Binding var reload: Bool
    var body: some View {
        ZStack {
            Color.lightbackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Create Habit")
                    .font(.largeTitle)
                    .bold()
                HStack(spacing: 14) {
                    Image(systemName: habit.type.icon)
                        .font(.title2)
                        .foregroundStyle(habit.type.color)
                        .frame(width: 52, height: 52)
                        .background(habit.type.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.type.displayName)
                            .font(.headline)
                            .bold()
                        
                        Text(habit.type.description)
                            .font(.footnote)
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    
                    Spacer()
                }
                .padding(18)
                .background(.cardcolor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                HStack {
                    Text("Habit")
                        .bold()
                    Spacer()
                    Picker("Habit", selection: $habit.type) {
                        ForEach(HabitType.allCases) { habit in
                            Text(habit.displayName).tag(habit)
                        }
                    }
                    // TODO, add description for each habit
                    // And maybe an Image
                }
                .padding(18)
                .background(.cardcolor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                VStack(alignment: .leading){
                    Text("Goal") // Your goal also sounds good. Kinda need to fill page out/personalzie
                        .bold()
                    Picker("Period", selection: $habit.period) {
                        Text("Daily").tag(HabitPeriod.day)
                        Text("Weekly").tag(HabitPeriod.week)
                    }
                    .pickerStyle(.segmented)
                    
                    Stepper(
                        "\(habit.targetCount) time\(habit.targetCount == 1 ? "" : "s") per \(habit.period == .day ? "day" : "week")",
                        value: $habit.targetCount,
                        in: 1...(habit.period == .day ? 10 : 14)
                    )
                    Text("You’ll need to complete this \(habit.targetCount) time\(habit.targetCount == 1 ? "" : "s") per \(habit.period == .day ? "day" : "week") to hit your goal.")
                                    .font(.footnote)
                                    .foregroundStyle(.black.opacity(0.55))
                }
                .padding(18)
                .background(.cardcolor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) {
                        Task {
                            habit.updatedAt = Date()
                            habit.isActive = true
                            let id = await HabitViewModel.saveHabit(habit: habit)
                            if id == nil {
                                print("Error: Save on DetailView did not work")
                            }
                            else {
                                reload.toggle()
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

