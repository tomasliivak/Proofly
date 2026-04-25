//
//  PhotoPreviewView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import SwiftUI
import AVFoundation
import Photos
import UIKit

struct PhotoPreviewView: View {
    var selectedHabit: Habit
    let item: IdentifiablePhotoData
    let onDismiss: () -> Void
    
    @State private var isScanning = false
    @State private var scanned = false
    @State private var scanResult = false
    @Environment(\.dismiss) private var dismiss
    private var previewImage: UIImage? {
        UIImage(data: item.data)
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button("Retake") {
                        onDismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.primarycolor)
                    Spacer()
                    Spacer()
                    Button("Log Your Habit") {
                        Task {
                            do {
                                isScanning = true
                                let result = try await APIClient.shared.uploadImageData(item.data)
                                print(result.success)
                                print(result.message)
                                print(result.labels ?? "No Labels")
                                if result.success == true { // Need to add thing saying task logged. Also need to add a loading thing to show loading
                                    if HabitMatcher.match(labels: result.labels ?? [], to: selectedHabit.type.localHabit) {
                                        let logged = await HabitLogViewModel.logHabitCompletion(habitId: selectedHabit.id ?? "", log: HabitLog(habitId: selectedHabit.id ?? "", createdAt: Date(), photoUrl: "", storagePath: ""), data: item.data)
                                        if logged == nil {
                                            isScanning = false
                                            scanResult = false
                                            scanned = true
                                            try? await Task.sleep(nanoseconds: 4000000000)
                                            print("Error: Save on HabitLog failed")
                                            scanned = false
                                            onDismiss()
                                        }
                                        else {
                                            
                                            isScanning = false
                                            scanResult = true
                                            scanned = true
                                            try? await Task.sleep(nanoseconds: 4000000000)
                                            scanned = false
                                            onDismiss()
                                            dismiss()
                                        }
                                    }
                                    else {
                                        isScanning = false
                                        scanResult = false
                                        scanned = true
                                        try? await Task.sleep(nanoseconds: 4000000000)
                                        scanned = false
                                        onDismiss()
                                        print("Photo did not match habit") // need to display this
                                    }
                                    
                                }
                            }
                            catch {
                                isScanning = false
                                scanResult = false
                                scanned = true
                                try? await Task.sleep(nanoseconds: 4000000000)
                                scanned = false
                                onDismiss()
                                print("Upload Failed \(error.localizedDescription)") // Add an alert or something?
                            }
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.primarycolor)
                }
                
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                } else {
                    ContentUnavailableView("Unable to Preview Photo", systemImage: "photo")
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        if scanned && !isScanning {
            if scanResult {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.green)
                        
                        Text("Habit Logged")
                            .font(.headline)
                            .bold()
                        
                        Text("Returning to dashboard...")
                            .font(.subheadline)
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    .frame(width: 260)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .background(.cardcolor)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
                    
                    Spacer()
                    Spacer()
                }
                
            } else {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                        
                        Text("Doesn’t Match Habit")
                            .font(.headline)
                            .bold()
                        
                        Text("Try again with a clearer photo")
                            .font(.subheadline)
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    .frame(width: 260)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .background(.cardcolor)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
                    
                    Spacer()
                    Spacer()
                }
            }
        }
        if isScanning {
            ProgressView()
                .scaleEffect(4)
                .tint(.red)
        }
    }
    
    //    private func savePhoto() {
    //        PHPhotoLibrary.shared().performChanges {
    //            let request = PHAssetCreationRequest.forAsset()
    //            request.addResource(with: .photo, data: item.data, options: nil)
    //        }
    //    }
}
