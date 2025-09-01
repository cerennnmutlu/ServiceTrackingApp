//
//  ProfileView.swift
//  ServiceTrackingAppUI
//
//  Created by AI on 29.08.2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var appState: AppState
    @State private var showingLogoutAlert = false
    @State private var showingErrorAlert = false
    // Removed navigateToSettings state as it's not needed with direct NavigationLink
    
    var body: some View {
        let mainContent = buildMainContent()
        
        VStack(spacing: 0) {
            mainContent
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProfileSettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                }
            }
        }
        .task {
             await viewModel.loadMe()
         }
        .onAppear {
            // Refresh profile data when view appears
            Task {
                await viewModel.loadMe()
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                appState.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("Retry") {
                Task {
                    await viewModel.loadMe()
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error ?? "An unknown error occurred")
        }
        .onChange(of: viewModel.error) { _, error in
            showingErrorAlert = error != nil
        }

    }
    
    @ViewBuilder
    private func buildMainContent() -> some View {
        if let user = viewModel.user {
            ScrollView {
                VStack(spacing: 24) {
                    buildProfileHeader(user: user)
                     buildPersonalInfoSection(user: user)
                     buildSettingsSection()
                     
                     Spacer(minLength: 100)
                 }
                 .padding(.horizontal, 16)
             }
         } else if viewModel.isLoading {
             buildLoadingView()
         } else {
             buildErrorView()
         }
     }
     
     @ViewBuilder
     private func buildProfileHeader(user: User) -> some View {
         VStack(spacing: 16) {
             // Profile Avatar
             ZStack {
                 let circleColor = Color.black.opacity(0.1)
                 Circle()
                     .fill(circleColor)
                     .frame(width: 80, height: 80)
                 
                 Image(systemName: "person.fill")
                     .font(.system(size: 40))
                     .foregroundColor(.black)
             }
             
             VStack(spacing: 4) {
                 Text(user.fullName ?? "Unknown User")
                     .font(.custom("Poppins-SemiBold", size: 20))
                     .foregroundColor(.primary)
                 
                 Text("@\(user.username ?? "unknown")")
                     .font(.custom("Poppins-Regular", size: 14))
                     .foregroundColor(.secondary)
             }
         }
         .padding(.top, 20)
     }
     
     @ViewBuilder
     private func buildPersonalInfoSection(user: User) -> some View {
         VStack(alignment: .leading, spacing: 16) {
             HStack {
                 Text("PERSONAL INFORMATION")
                     .font(.custom("Poppins-Medium", size: 12))
                     .foregroundColor(.secondary)
                     .textCase(.uppercase)
                     .tracking(0.5)
                 Spacer()
             }
            
             VStack(spacing: 0) {
                 ProfileInfoRow(
                     icon: "envelope",
                     title: "Email",
                     value: user.email ?? "N/A",
                     iconColor: .red
                 )
                
                 Divider()
                     .padding(.leading, 44)
                
                 ProfileInfoRow(
                     icon: "person.circle",
                     title: "Role",
                     value: user.roleName ?? "N/A",
                     iconColor: .red
                 )
             }
             .background(Color(.systemBackground))
             .cornerRadius(12)
             .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
         }
     }
     
     @ViewBuilder
     private func buildSettingsSection() -> some View {
         VStack(alignment: .leading, spacing: 16) {
             HStack {
                 Text("SETTINGS")
                     .font(.custom("Poppins-Medium", size: 12))
                     .foregroundColor(.secondary)
                     .textCase(.uppercase)
                     .tracking(0.5)
                 Spacer()
             }
            
             VStack(spacing: 0) {
                 ProfileActionRow(
                     icon: "bell",
                     title: "Notifications",
                     hasToggle: true,
                     iconColor: .red
                 )
                
                 Divider()
                     .padding(.leading, 44)
                
                 Button(action: {
                     showingLogoutAlert = true
                 }) {
                     ProfileActionRow(
                         icon: "rectangle.portrait.and.arrow.right",
                         title: "Logout",
                         isDestructive: true
                     )
                 }
                 .buttonStyle(PlainButtonStyle())
             }
             .background(Color(.systemBackground))
             .cornerRadius(12)
             .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
         }
     }
     
     @ViewBuilder
     private func buildLoadingView() -> some View {
         VStack(spacing: 16) {
             Spacer()
             ProgressView()
                 .scaleEffect(1.2)
             Text("Loading profile...")
                 .font(.custom("Poppins-Regular", size: 16))
                 .foregroundColor(.secondary)
             Spacer()
         }
     }
     
     @ViewBuilder
     private func buildErrorView() -> some View {
         ContentUnavailableView(
             "Profile Unavailable",
             systemImage: "person.slash",
             description: Text("Unable to load profile information. Please try again.")
         )
    }
}

// MARK: - Supporting Views
struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    var iconColor: Color = .blue
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 20, height: 20)
            
            Text(title)
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct ProfileActionRow: View {
    let icon: String
    let title: String
    var hasToggle: Bool = false
    var isDestructive: Bool = false
    var iconColor: Color = .blue
    @State private var toggleValue = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isDestructive ? .red : iconColor)
                .frame(width: 20, height: 20)
            
            Text(title)
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(isDestructive ? .red : .primary)
            
            Spacer()
            
            if hasToggle {
                Toggle("", isOn: $toggleValue)
                    .labelsHidden()
            } else if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AppState())
    }
}


