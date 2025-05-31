//
//  LoginView.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import UIKit
import SwiftUI
import CoreData

class LoginView: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        errorLabel.isHidden = true
        
        loginButton.backgroundColor = .black
        loginButton.titleLabel?.textColor = .white
        loginButton.layer.cornerRadius = 10
        GlobalViewModel.shared.loadData(context,
                                        entityName: CoreDataEntitys.user.rawValue,
                                        key: CoreDataEntitys.username.rawValue,
                                        type: String.self) { username in
            if username != nil {
                sendHome()
            }
        } failure: { }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loginTapped(UIButton())
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let username = usernameTextField.text?.lowercased() ?? ""
        let password = passwordTextField.text ?? ""
        
        if username == "admin" && password == "1234" {
            GlobalViewModel.shared.saveData(context,
                                            entityName: CoreDataEntitys.user.rawValue,
                                            key: CoreDataEntitys.username.rawValue,
                                            value: "admin") {
                sendHome()
            } failure: {
                sendHome()
            }
        } else {
            errorLabel.textColor = .red
            errorLabel.backgroundColor = .black
            errorLabel.text = "Usuario o contraseña incorrectos"
            errorLabel.isHidden = false
        }
    }
    
    func sendHome() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: HomeView().environment(\.managedObjectContext, context))
            window.makeKeyAndVisible()
        }
    }
}
