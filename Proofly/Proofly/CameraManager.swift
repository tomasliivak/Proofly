//
//  CameraManager.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import Foundation
import AVFoundation
import Combine

class CameraManager: NSObject, ObservableObject {
    
    @Published var capturedPhoto: IdentifiablePhotoData?
    @Published var isSessionRunning = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    // AVFoundation Components
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "com.customcamera.sessionQueue")
    
    override init() {
        super.init()
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationStatus = .authorized
            setupSession()
            
        case .notDetermined:
            authorizationStatus = .notDetermined
            AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.setupSession()
                    }
                }
                
            }
        case .denied, .restricted:
            authorizationStatus = .denied
        @unknown default:
            authorizationStatus = .denied
            
        }
    }
    
    // Config AVSetup
    
    private func setupSession() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else {return}
            
            // set session preset
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // add camera input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: camera) else {
                print("Failed to access camera")
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.currentInput = input
            }
            
            // add photo output
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                if let largestDimension = camera.activeFormat.supportedMaxPhotoDimensions.max(by: {
                    Int($0.width) * Int($0.height) < Int($1.width) * Int($1.height)
                }) {
                    self.photoOutput.maxPhotoDimensions = largestDimension
                }
                self.photoOutput.maxPhotoQualityPrioritization = .quality
            }
            
            self.session.commitConfiguration()
            
            // start the session
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    func capturePhoto() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            // config photo settings
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off // Flash is off for now...
            settings.photoQualityPrioritization = .quality
            settings.maxPhotoDimensions = self.photoOutput.maxPhotoDimensions
            self.photoOutput.capturePhoto(with: settings, delegate: self)
            
        }
    }
    
    func switchCamera() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else {return}
            
            self.session.beginConfiguration()
            
            // remove current input
            
            if let currentInput = self.currentInput {
                self.session.removeInput(currentInput)
            }
            
            // new camera position
            
            let currentPosition = self.currentInput?.device.position ?? .back
            let newPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
            
            // Get new camera device
            
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
                // fail to get new camera
                if let currentInput = self.currentInput,
                   self.session.canAddInput(currentInput) {
                    self.session.addInput(currentInput)
                }
                self.session.commitConfiguration()
                return
            }
            // add new camera output
            
            if self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
                self.currentInput = newInput
            }
            self.session.commitConfiguration()
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error \(error.localizedDescription)")
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to get photo data")
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.capturedPhoto = IdentifiablePhotoData(data: imageData)
        }
    }
}
    
    
struct IdentifiablePhotoData: Identifiable {
    let id = UUID().uuidString
    let data: Data
}
