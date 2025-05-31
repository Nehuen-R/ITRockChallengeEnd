//
//  LoginViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import Foundation
import CoreData
import SwiftUI

class LoginViewModel {
    var username: String = ""
    var password: String = ""
    var errorMessage: String?
    
    private let context: NSManagedObjectContext
        
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func isUserLoggedIn() -> Bool {
        let savedUsername = StorageService.shared.load(
            context: context,
            entity: CoreDataEntitys.user.rawValue,
            key: CoreDataEntitys.username.rawValue,
            as: String.self
        )
        return savedUsername != nil
    }
    
    func login() -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedUsername.isEmpty || trimmedPassword.isEmpty {
            errorMessage = ErrorLogger.empty.rawValue
            return false
        }
        
        if trimmedUsername == "admin" && trimmedPassword == "1234" {
            StorageService.shared.save(
                context: context,
                entity: CoreDataEntitys.user.rawValue,
                key: CoreDataEntitys.username.rawValue,
                value: "admin"
            )
            return true
        } else {
            errorMessage = ErrorLogger.badUserOrPassWord.rawValue
            return false
        }
    }
    
    func navigateToHome() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: HomeView().environment(\.managedObjectContext, context))
            window.makeKeyAndVisible()
        }
    }
}
