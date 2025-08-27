//
//  LoginView.swift
//  ServiceTrackingAppUI
//
//  Created by Ceren Mutlu on 27.08.2025.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @FocusState private var focusedField: Field?
    enum Field { case email, password }

    var body: some View {
        NavigationStack {
            if appState.isAuthenticated {
                MainView()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                            .padding(.top, 32)

                        loginForm

                        signUpSection
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .background(Color.white.ignoresSafeArea())
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .alert(isPresented: Binding(get: { errorMessage != nil },
                                    set: { _ in errorMessage = nil })) {
            Alert(title: Text("Login Error"),
                  message: Text(errorMessage ?? ""),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Image("BusIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)

            Text("ServiceTracker")
                .font(.custom("Poppins-Bold", size: 32))
                .foregroundColor(.red)

            Text("Welcome to our service tracking application")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var loginForm: some View {
        VStack(spacing: 16) {
            
            // Email / Username
            VStack(alignment: .leading, spacing: 6) {
                Text("Email or Username")
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.gray)

                TextField("Enter your email or username", text: $email)
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
            .padding(.top, 32)

            // Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.gray)

                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .font(.custom("Poppins-Regular", size: 16))
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }

                HStack {
                    Spacer()
                    Text("Forgot Password?")
                        .padding(.top, 6)
                        .font(.custom("Poppins-Medium", size: 14))
                        .foregroundColor(.red)
                }
            }

            Button(action: didTapLogin) {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding()
                } else {
                    Text("Login")
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
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
        }
    }

    private var signUpSection: some View {
        HStack(spacing: 6) {
            Text("Don't have an account?")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)

            NavigationLink(destination: SignUpView()) {
                Text("Sign Up")
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Actions

    private func didTapLogin() {
        focusedField = nil
        let u = email.trimmingCharacters(in: .whitespacesAndNewlines)
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await AuthService(appState: appState).login(email: u, password: password)
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview { LoginView().environmentObject(AppState()) }
