//
//  RootView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RootView: View {
    @State var isLoggedIn = false // need to change to false
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
            }
            else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // if logged in when app runs, navigate to the new screen & skip login screen
            if Auth.auth().currentUser != nil {
                print("🪵 Login Successful!")
                isLoggedIn = true
            }
        }
        
    }
    
}

#Preview {
    RootView()
}
