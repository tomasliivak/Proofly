//
//  MainTabView.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    
    @State var selectedSection: AppSection = .log
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedSection {
                case .log:
                    LogView(selectedSection: $selectedSection)
                case .habits:
                    HabitsView(selectedSection: $selectedSection)
                case .progress:
                    EmptyView()
                case .profile:
                    ProfileView(isLoggedIn: $isLoggedIn)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.lightbackground)
            HStack(spacing: 12) {
                Spacer()
                Button {
                    selectedSection = .log
                } label: {
                    VStack {
                        Image(systemName: "camera.fill")
                        Text("Log")
                    }
                    .font(.title3)
                    .foregroundStyle(selectedSection == .log ? .primarycolor : .grayedoutcolor)
                }
                Spacer()
                Button {
                    selectedSection = .habits
                } label: {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Habits")
                    }
                    .font(.title3)
                    .foregroundStyle(selectedSection == .habits ? .primarycolor : .grayedoutcolor)
                }
                Spacer()
                Button {
                    selectedSection = .profile
                } label: {
                    VStack {
                        Image(systemName: "person.circle.fill")
                        Text("Profile")
                    }
                    .font(.title3)
                    .foregroundStyle(selectedSection == .profile ? .primarycolor : .grayedoutcolor)
                }
                Spacer()
            }
            .padding(.top, 20)
            .background(.cardcolor)
        }
    }
}

