//
//  ContentView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import SwiftUI
import AVFoundation
import AVKit

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var habits: [Habit] = []
    @State private var selectedHabitid = Habit().id
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            if let item = cameraManager.capturedPhoto, let selectedHabit = habits.first(where: { $0.id == selectedHabitid }) {
                PhotoPreviewView(selectedHabit: selectedHabit, item: item, onDismiss: {
                    cameraManager.capturedPhoto = nil
                })
            } else {
                cameraCaptureContent
            }
        }
        .background(.lightbackground)
        .onAppear {
            cameraManager.checkAuthorization()
        }
        .task {
            habits = await HabitViewModel.getHabits()
            if !habits.isEmpty {
                selectedHabitid = habits.first!.id // this may be broken
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
        }
    }

    private var cameraCaptureContent: some View {
        ZStack {
            if cameraManager.authorizationStatus == .authorized {
                CameraPreview(session: cameraManager.session)
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding()
                
                HStack{
                    Text("Habit:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .bold()
                    Picker("Habit", selection: $selectedHabitid) {
                        ForEach(habits) { habit in
                            Text(habit.type.displayName)
                                .tag(habit.id)
                                .foregroundStyle(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 150)
                    .clipped()
                }
                .offset(y: 150)
                VStack {
//                    HStack{
//                        Text("Habit:")
//                            .font(.title2)
//                        Picker("Habit", selection: $selectedHabitid) {
//                            ForEach(habits) { habit in
//                                Text(habit.type.displayName)
//                                    .tag(habit.id) // must match selection type
//                            }
//                        }
//                        .pickerStyle(.wheel)
//                        .frame(width: 100, height: 150)
//                        .clipped()
//                    }
                    Text("Capture Your Habit")
                        .font(.title)
                        .bold()
                    Text("Take a photo of an item related to your habit")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.6))
                    Spacer()
                    Spacer()

                    ZStack {
                        Button {
                            cameraManager.capturePhoto()
                        } label: {
                            Circle()
                                .strokeBorder(.primarycolor, lineWidth: 3)
                                .frame(width: 70, height: 70)
                                .overlay {
                                    Circle()
                                        .fill(.primarycolor)
                                        .frame(width: 60, height: 60)
                                }
                        }

                        HStack {
                            Spacer()

                            Button {
                                cameraManager.switchCamera()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .font(.largeTitle)
                                    .foregroundStyle(.primarycolor)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 40)
                }
            } else {
                permissionView
            }
        }
    }

    private var permissionView: some View {
        VStack {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.gray)

            Text("Camera Access Required")

            if cameraManager.authorizationStatus == .denied {
                Text("Please enable camera in settings")

                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            }
        }
        .background(.lightbackground)
    }
}

#Preview {
    NavigationStack {
        CameraView()
    }
}
