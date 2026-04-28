# Proofly

## Summary
An iOS app that helps users build daily habits using photo verification and AI image labeling. Users capture images of actions (e.g. studying, drinking water), which are analyzed and logged to track consistency and progress over time.

## Technologies Used
- SwiftUI (iOS frontend)
- Node.js / Express (backend API)
- Firebase Authentication
- Firebase Firestore
- Firebase Storage
- Cloud Vision API (image labeling)
- Alamofire API Requests
- AVFoundation Camera Integration

## Screenshots

<p align="center">
  <img src="./screenshots/log.jpg" alt="Home Screen" width="250"/>
  <img src="./screenshots/camera.jpg" alt="Camera / Logging" width="250"/>
  <img src="./screenshots/habits.jpg" alt="Stats Page" width="250"/>
</p>

## Demo Video
[Watch Demo](https://www.youtube.com/watch?v=J-94mdp_NZ0)

## Setup Instructions

### Prerequisites

- Xcode
- Node.js v18+
- Firebase project
- Google Cloud project with Cloud Vision API enabled

---

## 1. Clone the Repository

Run:

    git clone https://github.com/tomasliivak/Proofly
    cd Proofly

Project structure:

    Proofly/
    ├── Proofly/
    └── swiftprojectbackend/

---

## 2. iOS Setup

Create this file:

    ios/Proofly/Secrets.swift

Add this inside Secrets.swift:

    import Foundation

    struct Secrets {
        static let backendURL = "http://YOUR_LOCAL_IP:3000/api/label"
    }

### Local Network Setup (Required for Real iPhone)

Since the app runs on your physical iPhone(Camera implemenation does not work as intended in simulator), you must use your computer’s local IP address instead of `localhost`.

On macOS (Wi-Fi):

    ipconfig getifaddr en0

If that returns nothing (e.g. Ethernet), try:

    ipconfig getifaddr en1

Use the returned IP in `Secrets.swift`:

    static let backendURL = "http://YOUR_IP:3000"

Notes:
- Your iPhone and computer must be on the same Wi-Fi network
- `localhost` will NOT work on a real device

---

## 3. Backend Setup

Move into the backend folder:

    cd swiftprojectbackend

Install dependencies:

    npm install

Create a .env file:

    touch .env

Add this inside backend/.env:

    GOOGLE_SERVICE_ACCOUNT_JSON=(explained later)
    PORT=3000

Start the backend:

    npm run dev

If that script is not available, run:

    node src/server.js

---

## 4. Firebase Setup

This project uses:

- Firebase Authentication
- Firebase Firestore
- Firebase Storage

In Firebase Console:

1. Create a Firebase project.
2. Enable Authentication.
3. Enable Firestore Database.
4. Enable Storage.
5. Add an iOS app.
6. Download GoogleService-Info.plist.
7. Add it to the Xcode project target.

---

## 5. Google Cloud Vision Setup

This project uses Google Cloud Vision through a Google Cloud service account.

1. Go to Google Cloud Console.
2. Enable the Cloud Vision API.
3. Create a service account.
4. Grant it permission to use Cloud Vision.
5. Generate a JSON key for the service account.
6. Store the JSON key as a single-line environment variable in backend/.env.

Example backend/.env format:

    GOOGLE_SERVICE_ACCOUNT_JSON='{"type":"service_account","project_id":"your-project-id","private_key_id":"your-private-key-id","private_key":"-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n","client_email":"your-service-account@your-project.iam.gserviceaccount.com","client_id":"your-client-id","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"your-cert-url","universe_domain":"googleapis.com"}'

---

## 6. Running the Project

1. Start the backend server.
2. Open the iOS project in Xcode.
3. Confirm Secrets.swift points to the correct backend URL.
4. Run the app on a physical iphone (Camera implementation does not work as intended in simulator)
