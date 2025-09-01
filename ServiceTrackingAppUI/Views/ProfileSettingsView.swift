//
//  ProfileSettingsView.swift
//  ServiceTrackingAppUI
//
//  Created by AI on 29.08.2025.
//

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.custom("Poppins-Bold", size: 24))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Settings Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("PROFILE SETTINGS")
                                    .font(.custom("Poppins-Medium", size: 12))
                                    .foregroundColor(.gray)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                Spacer()
                            }
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: EditProfileView()) {
                                    SettingsRow(
                                        icon: "person.circle",
                                        title: "Edit Profile",
                                        subtitle: "Update your personal information"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                NavigationLink(destination: ChangePasswordView()) {
                                    SettingsRow(
                                        icon: "lock.circle",
                                        title: "Change Password",
                                        subtitle: "Update your account password"
                                    )
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        // App Settings Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("APP SETTINGS")
                                    .font(.custom("Poppins-Medium", size: 12))
                                    .foregroundColor(.gray)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                Spacer()
                            }
                            
                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "bell.circle",
                                    title: "Notifications",
                                    subtitle: "Manage notification preferences",
                                    hasToggle: true
                                )
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                SettingsRow(
                                    icon: "moon.circle",
                                    title: "Dark Mode",
                                    subtitle: "Switch between light and dark theme",
                                    hasToggle: true
                                )
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                SettingsRow(
                                    icon: "globe",
                                    title: "Language",
                                    subtitle: "Change app language",
                                    action: {}
                                )
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)

            .overlay(alignment: .topTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
        }
    }
}

struct ProfileFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundColor(.black)
            
            if isMultiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(CustomTextFieldStyle())
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(CustomTextFieldStyle())
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom("Poppins-Regular", size: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .disabled(false)
    }
}

struct PasswordFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundColor(.black)
            
            HStack {
                if isVisible {
                    TextField(placeholder, text: $text)
                        .font(.custom("Poppins-Regular", size: 16))
                        .textInputAutocapitalization(.never)
                        .disabled(false)
                } else {
                    SecureField(placeholder, text: $text)
                        .font(.custom("Poppins-Regular", size: 16))
                        .textInputAutocapitalization(.never)
                        .disabled(false)
                }
                
                Button(action: {
                    isVisible.toggle()
                }) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
                .font(.system(size: 12))
            
            Text(text)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(isMet ? .green : .gray)
            
            Spacer()
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var hasToggle: Bool = false
    var action: (() -> Void)? = nil
    @State private var toggleValue = true
    
    var body: some View {
        HStack(spacing: 12) {
             Image(systemName: icon)
                 .font(.system(size: 20))
                 .foregroundColor(.red)
                 .frame(width: 24, height: 24)
             
             VStack(alignment: .leading, spacing: 2) {
                 Text(title)
                     .font(.custom("Poppins-Medium", size: 16))
                     .foregroundColor(.black)
                     .frame(maxWidth: .infinity, alignment: .leading)
                 
                 Text(subtitle)
                     .font(.custom("Poppins-Regular", size: 13))
                     .foregroundColor(.gray)
                     .frame(maxWidth: .infinity, alignment: .leading)
             }
             
             if hasToggle {
                 Toggle("", isOn: $toggleValue)
                     .labelsHidden()
                     .tint(.red)
             } else {
                 Image(systemName: "chevron.right")
                     .font(.system(size: 12))
                     .foregroundColor(.gray)
             }
         }
         .padding(.horizontal, 16)
         .padding(.vertical, 16)
    }
}

// Placeholder views for Edit Profile and Change Password
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var fullName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Photo Section
                        VStack(spacing: 16) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                }
                            
                            Button("Change Photo") {
                                // Photo change functionality
                            }
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.red)
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            ProfileFormField(title: "Full Name", text: $fullName, placeholder: "Enter your full name")
                            ProfileFormField(title: "Username", text: $username, placeholder: "Enter your username")
                            ProfileFormField(title: "Email", text: $email, placeholder: "Enter your email", keyboardType: .emailAddress)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 120)
                    }
                }
                
                // Save Button at Bottom
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        saveProfile()
                    }) {
                        HStack {
                            if profileViewModel.isUpdatingProfile {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Saving...")
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(.white)
                            } else {
                                Text("Save Changes")
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(profileViewModel.isUpdatingProfile ? Color.red.opacity(0.7) : Color.red)
                        .cornerRadius(12)
                    }
                    .disabled(profileViewModel.isUpdatingProfile)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                    .font(.custom("Poppins-Medium", size: 16))
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .onChange(of: profileViewModel.successMessage) { message in
            if let message = message {
                alertMessage = message
                showingAlert = true
                profileViewModel.clearMessages()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
        .onChange(of: profileViewModel.error) { error in
            if let error = error {
                alertMessage = error
                showingAlert = true
                profileViewModel.clearMessages()
            }
        }
        .alert("Profile Update", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadUserData() {
        if let user = profileViewModel.user {
            fullName = user.fullName
            username = user.username
            email = user.email
        } else {
            profileViewModel.loadMe()
        }
    }
    
    private func saveProfile() {
        // Validation
        guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter your full name"
            showingAlert = true
            return
        }
        
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter your username"
            showingAlert = true
            return
        }
        
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter your email"
            showingAlert = true
            return
        }
        
        guard isValidEmail(email) else {
            alertMessage = "Please enter a valid email address"
            showingAlert = true
            return
        }
        
        // Call API to update profile
        profileViewModel.updateProfile(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isCurrentPasswordVisible = false
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            
                            Text("Change Password")
                                .font(.custom("Poppins-Bold", size: 24))
                                .foregroundColor(.black)
                            
                            Text("Enter your current password and choose a new secure password")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // Password Fields
                        VStack(spacing: 20) {
                            PasswordFormField(
                                title: "Current Password",
                                text: $currentPassword,
                                placeholder: "Enter your current password",
                                isVisible: $isCurrentPasswordVisible
                            )
                            
                            PasswordFormField(
                                title: "New Password",
                                text: $newPassword,
                                placeholder: "Enter your new password",
                                isVisible: $isNewPasswordVisible
                            )
                            
                            PasswordFormField(
                                title: "Confirm New Password",
                                text: $confirmPassword,
                                placeholder: "Confirm your new password",
                                isVisible: $isConfirmPasswordVisible
                            )
                            
                            // Password Requirements
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password Requirements:")
                                    .font(.custom("Poppins-Medium", size: 14))
                                    .foregroundColor(.black)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    PasswordRequirement(text: "At least 8 characters", isMet: newPassword.count >= 8)
                                    PasswordRequirement(text: "Contains uppercase letter", isMet: newPassword.rangeOfCharacter(from: .uppercaseLetters) != nil)
                                    PasswordRequirement(text: "Contains lowercase letter", isMet: newPassword.rangeOfCharacter(from: .lowercaseLetters) != nil)
                                    PasswordRequirement(text: "Contains number", isMet: newPassword.rangeOfCharacter(from: .decimalDigits) != nil)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 120)
                    }
                }
                
                // Update Button at Bottom
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        changePassword()
                    }) {
                        HStack {
                            if profileViewModel.isChangingPassword {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Updating...")
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(.white)
                            } else {
                                Text("Update Password")
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(profileViewModel.isChangingPassword ? Color.red.opacity(0.7) : Color.red)
                        .cornerRadius(12)
                    }
                    .disabled(profileViewModel.isChangingPassword)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                    .font(.custom("Poppins-Medium", size: 16))
                }
            }
        }
        .onChange(of: profileViewModel.successMessage) { message in
            if let message = message {
                alertMessage = message
                showingAlert = true
                profileViewModel.clearMessages()
                // Clear password fields on success
                currentPassword = ""
                newPassword = ""
                confirmPassword = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
        .onChange(of: profileViewModel.error) { error in
            if let error = error {
                alertMessage = error
                showingAlert = true
                profileViewModel.clearMessages()
            }
        }
        .alert("Password Change", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func changePassword() {
        // Validation
        guard !currentPassword.isEmpty else {
            alertMessage = "Please enter your current password"
            showingAlert = true
            return
        }
        
        guard !newPassword.isEmpty else {
            alertMessage = "Please enter a new password"
            showingAlert = true
            return
        }
        
        guard newPassword.count >= 8 else {
            alertMessage = "Password must be at least 8 characters long"
            showingAlert = true
            return
        }
        
        guard newPassword.rangeOfCharacter(from: .uppercaseLetters) != nil else {
            alertMessage = "Password must contain at least one uppercase letter"
            showingAlert = true
            return
        }
        
        guard newPassword.rangeOfCharacter(from: .lowercaseLetters) != nil else {
            alertMessage = "Password must contain at least one lowercase letter"
            showingAlert = true
            return
        }
        
        guard newPassword.rangeOfCharacter(from: .decimalDigits) != nil else {
            alertMessage = "Password must contain at least one number"
            showingAlert = true
            return
        }
        
        // Check for special characters
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':,.<>?")
        guard newPassword.rangeOfCharacter(from: specialCharacters) != nil else {
            alertMessage = "Password must contain at least one special character (!@#$%^&*()_+-=[]{}|;':,.<>?)"
            showingAlert = true
            return
        }
        
        guard newPassword == confirmPassword else {
            alertMessage = "New passwords do not match"
            showingAlert = true
            return
        }
        
        guard currentPassword != newPassword else {
            alertMessage = "New password must be different from current password"
            showingAlert = true
            return
        }
        
        // Call API to change password
        profileViewModel.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
    }
}

#Preview {
    ProfileSettingsView()
}