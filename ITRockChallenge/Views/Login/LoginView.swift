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
    
    private var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel(context: context)
        setupUI()
        
        if viewModel.isUserLoggedIn() {
            viewModel.navigateToHome()
        }
    }
    
    func setupUI() {
        view.backgroundColor = .gray
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        errorLabel.isHidden = true
        loginButton.backgroundColor = .black
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loginTapped(loginButton)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        viewModel.username = usernameTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        
        if viewModel.login() {
            viewModel.navigateToHome()
        } else {
            errorLabel.text = viewModel.errorMessage
            errorLabel.textColor = .red
            errorLabel.backgroundColor = .black
            errorLabel.isHidden = false
        }
    }
}
