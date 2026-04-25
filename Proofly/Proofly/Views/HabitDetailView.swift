//
//  HabitDetailView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/24/26.
//

import SwiftUI

struct HabitDetailView: View {
    @State var habit: Habit
    @State var logs: [HabitLog] = []
    @State private var logVM = HabitLogViewModel()
    @State var showEdit = false
    @State var progress = HabitProgress(completedCount: 0, targetCount: 0, isComplete: false)
    @State var progressDouble = 0.0
    @Binding var reload: Bool
    var body: some View {
        if !showEdit {
            VStack{
                HStack {
                    Spacer()
                    Button {
                        showEdit.toggle()
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.primarycolor)
                }
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
                HStack{
                    VStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.title)
                        Text("Current Streak")
                            .foregroundStyle(.black.opacity(0.7))
                            .frame(maxWidth: .infinity)
                        let streak = StreakCalculator.dailyStreak(logs: logs, targetCount: habit.targetCount)
                        Text("\(streak) Day\(streak == 1 ? "" : "s")")
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
                                .trim(from:0, to:progressDouble)
                                .stroke(
                                    .primarycolor,
                                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                            VStack{
                                Text("\(progress.completedCount)/\(progress.targetCount)")
                                    .font(.title3)
                                    .bold()
                                Text("Today")
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
                
                if !logs.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Logged Photos")
                            .font(.headline)
                            .bold()
                        
                        TabView {
                            ForEach(logs) { log in
                                if let url = URL(string: log.photoUrl), !log.photoUrl.isEmpty {
                                    AsyncImage(url: url) { phase in
                                        ZStack {
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                
                                            } else if phase.error != nil {
                                                VStack(spacing: 10) {
                                                    Image(systemName: "questionmark.square.dashed")
                                                        .font(.largeTitle)
                                                        .foregroundStyle(.gray)
                                                    
                                                    Text("Couldn’t Load Photo")
                                                        .font(.headline)
                                                    
                                                    Text("The image link may be missing or expired.")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.black.opacity(0.55))
                                                }
                                                
                                            } else {
                                                VStack(spacing: 12) {
                                                    ProgressView()
                                                        .scaleEffect(1.4)
                                                        .tint(.primarycolor)
                                                    
                                                    Text("Loading photo...")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.black.opacity(0.55))
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(.cardcolor)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                        }
                        .frame(height: 260)
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                    }
                    .padding(.top, 12)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .background(.lightbackground)
            .task {
                logs = await HabitLogViewModel.getLogs(for: habit.id ?? "")
                progress = HabitProgressCalculator.progress(for: habit, logs: logs)
                if progress.targetCount != 0 {
                    if progress.completedCount > progress.targetCount {
                        progressDouble = Double(progress.targetCount) / Double(progress.targetCount)
                    }
                    else {
                        progressDouble = Double(progress.completedCount) / Double(progress.targetCount)
                    }
                }
            }
            
        }
        else {
            HabitEditView(habit: habit, reload: $reload)
        }
    }
}

