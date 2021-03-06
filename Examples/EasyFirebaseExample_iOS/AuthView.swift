//
//  AuthView.swift
//  EasyFirebaseExample_iOS
//
//  Created by Ben Myers on 2/6/22.
//

import SwiftUI
import EasyFirebase

/**
 This view assists with learning `EasyAuth`.
 */
struct AuthView: View {
  
  // MARK: - Wrapped Properties
  
  /// The Global `EnvironmentObject`.
  @EnvironmentObject var global: Global
  
  /// The field holding the email input.
  @State var emailField: String = ""
  /// The field holding the password input.
  @State var passwordField: String = ""
  /// The error that occured, if any.
  @State var error: String? = nil
  
  // MARK: - Body View
  
  var body: some View {
    VStack {
      errorView
      if let user = global.user, user.id != "Guest" {
        infoView
      } else {
        fieldsView
      }
    }.padding()
  }
  
  // MARK: - Supporting Views
  
  /// A view displaying an error that occured, if any.
  var errorView: some View {
    Group {
      if let error = error {
        Text(error).foregroundColor(.red)
      }
    }
  }
  
  /// A view that assists with account creation and signing in.
  var fieldsView: some View {
    VStack {
      TextField("Email", text: $emailField)
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
      TextField("Password", text: $passwordField)
        .textContentType(.password)
      HStack {
        Button(action: signIn) {
          Text("Sign In")
        }
        Spacer().frame(width: 50.0)
        Button(action: createAccount) {
          Text("Create Account")
        }
      }
      Button(action: signInWithGoogle) {
        Text("Sign in with Google")
      }
      Button(action: signInWithApple) {
        Text("Sign in with Apple")
      }
    }
  }
  
  /// Displays available information about the user.
  var infoView: some View {
    VStack {
      Text("You are signed in.")
        .fontWeight(.bold)
      Text("Username: \(global.user.username)")
      Text("Email: \(global.user.email)")
      Text("Display Name: \(global.user.displayName)")
      Button(action: signOut) {
        Text("Sign Out")
      }
    }
  }
  
  // MARK: - Methods
  
  /**
   Signs in the user.
   */
  func signIn() {
    EasyAuth.signIn(email: emailField, password: passwordField) { error in
      self.error = error?.localizedDescription
    }
  }
  
  /**
   Signs in the user using Sign in with Google.
   */
  func signInWithGoogle() {
    EasyAuth.signInWithGoogle(clientID: "42500151564-vfh7ehpcbmjf7n6p6p8htbccpnvod5c4")
  }
  
  /**
   Signs in the user using Sign in with Apple.
   */
  func signInWithApple() {
    EasyAuth.signInWithApple()
  }
  
  /**
   Creates a new account for the user.
   */
  func createAccount() {
    EasyAuth.createAccount(email: emailField, password: passwordField) { error in
      self.error = error?.localizedDescription
    }
  }
  
  /**
   Signs out the user.
   */
  func signOut() {
    EasyAuth.signOut()
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}
