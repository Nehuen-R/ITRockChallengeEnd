//
//  PaymentView.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import UIKit

class PaymentView: UIViewController, UITextFieldDelegate {
    var product: ProductProtocol?

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expirationMonthField: UITextField!
    @IBOutlet weak var expirationYearField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNumberField.delegate = self
        expirationMonthField.delegate = self
        expirationYearField.delegate = self
        cvvField.delegate = self
        self.cardNumberField.keyboardType = .numberPad
        self.expirationMonthField.keyboardType = .numberPad
        self.expirationYearField.keyboardType = .numberPad
        self.cvvField.keyboardType = .numberPad
        
        guard let product = product else { return }
        
        self.productTitle.text = product.title
        self.productPrice.text = "Total a pagar: \(product.priceText)"
        
        if let url = URL(string: product.image) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async {
                    if let data = data, error == nil, let image = UIImage(data: data) {
                        self.productImage.image = image
                    } else {
                        self.productImage.image = UIImage(systemName: "xmark.octagon")
                        self.productImage.tintColor = .red
                    }
                }
            }.resume()
        } else {
            self.productImage.image = UIImage(systemName: "xmark.octagon")
            self.productImage.tintColor = .red
        }
        
        errorLabel.text = ""
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
    }

    @IBAction func confirmPayment(_ sender: Any) {
        let validCard = "1234567891234567"
        let validExpiration = "12/27"
        let validCVV = "123"

        guard let number = cardNumberField.text?.replacingOccurrences(of: " ", with: ""),
              let cvv = cvvField.text,
              let month = expirationMonthField.text, !month.isEmpty,
              let year = expirationYearField.text, !year.isEmpty,
              !number.isEmpty, !cvv.isEmpty else {
            errorLabel.text = "Por favor complete todos los campos"
            errorLabel.textColor = .red
            return
        }
        
        let expiration = "\(month)/\(year)"

        if number == validCard && expiration == validExpiration && cvv == validCVV {
            let alert = UIAlertController(
                title: "Pago exitoso",
                message: "Gracias por tu compra.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            present(alert, animated: true, completion: nil)
        } else {
            errorLabel.text = "Tarjeta inválida. Intente nuevamente."
            errorLabel.textColor = .red
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        confirmPayment(UIButton())
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardNumberField {
            guard let text = textField.text else { return false }

            let allowedChars = CharacterSet.decimalDigits
            if string.rangeOfCharacter(from: allowedChars.inverted) != nil && string != "" {
                return false
            }

            let currentText = text.replacingOccurrences(of: " ", with: "")
            guard let stringRange = Range(range, in: text) else { return false }
            let updatedText = text.replacingCharacters(in: stringRange, with: string)
            let cleanedText = updatedText.replacingOccurrences(of: " ", with: "")

            if cleanedText.count > 16 { return false }

            var formatted = ""
            for (index, character) in cleanedText.enumerated() {
                if index > 0 && index % 4 == 0 {
                    formatted.append(" ")
                }
                formatted.append(character)
            }

            textField.text = formatted
            return false
        }

        let limits: [UITextField: Int] = [
            expirationMonthField: 2,
            expirationYearField: 2,
            cvvField: 3
        ]

        if let maxLength = limits[textField],
           let currentText = textField.text,
           let stringRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= maxLength
        }

        return true
    }
}

