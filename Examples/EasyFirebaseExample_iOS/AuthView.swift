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
      Text("Fav Food: \(global.user.favoriteFood)")
      Text("Age: \(global.user.age)")
      Text("Has Job: \(String(global.user.hasJob))")
    }
  }
  
  // MARK: - Methods
  
  func signIn() {
    EasyAuth.signIn(email: emailField, password: passwordField) { error in
      self.error = error?.localizedDescription
    }
  }
  
  func createAccount() {
    EasyAuth.createAccount(email: emailField, password: passwordField) { error in
      self.error = error?.localizedDescription
    }
  }
  
  func signOut() {
    EasyAuth.signOut()
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}

EasyAuth.signOut()
