//
//  SignUpView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage = false

    @FocusState private var focusedField: Field?
    enum Field { case name, email, password, confirmPassword }

    var body: some View {
        // Kendi NavigationStack'i yok; üstten NavigationLink ile gelmeli
        ScrollView {
            VStack(spacing: 16) {
                headerView
                    .padding(.top, 16)

                signUpForm

                loginSection
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(Color.white.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.custom("Poppins-Medium", size: 16))
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationBarBackButtonHidden(true) // sistem geri okunu gizle
        .alert(isPresented: Binding(get: { errorMessage != nil },
                                    set: { _ in errorMessage = nil })) {
            Alert(title: Text("Sign Up Error"),
                  message: Text(errorMessage ?? ""),
                  dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Registration Successful"),
                  message: Text("Your account has been created. Please log in."),
                  dismissButton: .default(Text("OK")) {
                      dismiss()
                  })
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Registration Successful"),
                  message: Text("Your account has been created. Please log in."),
                  dismissButton: .default(Text("OK")) {
                      dismiss()
                  })
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Image("BusIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            Text("ServiceTracker")
                .font(.custom("Poppins-Bold", size: 32))
                .foregroundColor(.red)

            Text("Create your account to get started")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var signUpForm: some View {
        VStack(spacing: 16) {

            // Full Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Full Name")
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.gray)

                TextField("Enter your full name", text: sanitized($name))
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .font(.custom("Poppins-Regular", size: 16))
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
            }
            .padding(.top, 8)

            // Email
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.gray)

                TextField("Enter your email address", text: sanitized($email))
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .font(.custom("Poppins-Regular", size: 16))
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }

            // Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.gray)

                SecureField("Enter your password", text: $password) // ← sanitize YOK
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .font(.custom("Poppins-Regular", size: 16))
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .confirmPassword }
            }

            // Confirm Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.gray)

                SecureField("Confirm your password", text: $confirmPassword) // ← sanitize YOK
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .font(.custom("Poppins-Regular", size: 16))
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
            }

            Button(action: didTapSignUp) {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding()
                } else {
                    Text("Sign Up")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(
                LinearGradient(colors: [Color.red, Color.red.opacity(0.8)],
                               startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .shadow(color: Color.red.opacity(0.25), radius: 8, x: 0, y: 3)
            .disabled(isLoading || isFormInvalid)
            .opacity((isLoading || isFormInvalid) ? 0.6 : 1.0)
        }
    }

    private var loginSection: some View {
        HStack(spacing: 6) {
            Text("Already have an account?")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)

            Button {
                dismiss()
            } label: {
                Text("Login")
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Helpers

    private var isFormInvalid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty
    }

    private func didTapSignUp() {
        focusedField = nil
        errorMessage = nil
        isLoading = true

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return finishWithError("Please enter your full name.") }
        guard email.contains("@"), email.contains(".") else { return finishWithError("Please enter a valid email address.") }
        
        // Enhanced password validation
        guard password.count >= 8 else { return finishWithError("Password must be at least 8 characters long.") }
        
        guard password.rangeOfCharacter(from: .uppercaseLetters) != nil else {
            return finishWithError("Password must contain at least one uppercase letter.")
        }
        
        guard password.rangeOfCharacter(from: .lowercaseLetters) != nil else {
            return finishWithError("Password must contain at least one lowercase letter.")
        }
        
        guard password.rangeOfCharacter(from: .decimalDigits) != nil else {
            return finishWithError("Password must contain at least one number.")
        }
        
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':,.<>?")
        guard password.rangeOfCharacter(from: specialCharacters) != nil else {
            return finishWithError("Password must contain at least one special character (!@#$%^&*()_+-=[]{}|;':,.<>?).")
        }
        
        guard password == confirmPassword else { return finishWithError("Passwords do not match.") }

        // Basit username stratejisi: email @ öncesi yoksa ad-soyad slug
        let username: String = {
            if let beforeAt = email.split(separator: "@").first, !beforeAt.isEmpty {
                return String(beforeAt)
            }
            return trimmedName
                .lowercased()
                .components(separatedBy: .whitespaces)
                .joined(separator: ".")
        }()

        Task {
            do {
                print("🔄 Starting registration process...")
                let auth = AuthService(appState: appState)
                try await auth.register(fullName: trimmedName,
                                        username: username,
                                        email: email,
                                        password: password)

                print("✅ Registration successful")
                isLoading = false
                
                // Başarılı kayıt mesajı göster ve login ekranına yönlendir
                await MainActor.run {
                    errorMessage = nil
                    // Başarı mesajı için alert göster
                    showSuccessMessage = true
                }
                
            } catch {
                print("❌ Registration failed: \(error)")
                isLoading = false
                
                // Daha detaylı hata mesajları
                if let apiError = error as? APIError {
                    switch apiError {
                    case .server(let status, let body):
                        errorMessage = "Server error (\(status)): \(body ?? "Unknown error")"
                    case .unauthorized:
                        errorMessage = "Authentication failed. Please check your credentials."
                    case .network(let networkError):
                        errorMessage = "Network error: \(networkError.localizedDescription)"
                    default:
                        errorMessage = "API error: \(apiError.localizedDescription)"
                    }
                } else {
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }


    private func finishWithError(_ message: String) {
        isLoading = false
        errorMessage = message
    }

    /// Her set'te klavye girdisini normalize eden Binding wrapper (sadece name & email'de kullan)
    private func sanitized(_ source: Binding<String>) -> Binding<String> {
        Binding(
            get: { source.wrappedValue },
            set: { source.wrappedValue = $0.fixMacKeyboardInput() }
        )
    }
}

#Preview {
    NavigationStack {   // Önizlemede nav bar görünsün
        SignUpView()
            .tint(.red)
    }
}
