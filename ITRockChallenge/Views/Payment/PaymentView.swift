//
//  PaymentView.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import UIKit
import Combine

class PaymentView: UIViewController, UITextFieldDelegate {
    var product: ProductProtocol?
    var viewModel = PaymentViewModel()
    var cancellables = Set<AnyCancellable>()

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
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        [productImage, productTitle, productPrice, cardNumberField, expirationMonthField, expirationYearField, cvvField].forEach {
            $0?.backgroundColor = .gray.withAlphaComponent(0.25)
            $0?.layer.cornerRadius = 20
            $0?.layer.masksToBounds = true
        }
        
        [cardNumberField, expirationMonthField, expirationYearField, cvvField].forEach {
            $0?.delegate = self
            $0?.keyboardType = .numberPad
        }

        errorLabel.text = ""

        if let product = product {
            productTitle.text = product.title
            productPrice.text = "Total a pagar: \(product.priceText)"
            if let url = URL(string: product.image) {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    DispatchQueue.main.async {
                        self.productImage.image = data.flatMap { UIImage(data: $0) } ?? UIImage(systemName: "xmark.octagon")
                        self.productImage.tintColor = .red
                    }
                }.resume()
            }
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private func bindViewModel() {
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.errorLabel.text = message
                self?.errorLabel.textColor = .red
            }
            .store(in: &cancellables)
        
        viewModel.$paymentSuccess
            .filter { $0 }
            .sink { [weak self] _ in self?.showSuccessAlert() }
            .store(in: &cancellables)
    }

    @IBAction func confirmPayment(_ sender: Any) {
        viewModel.cardNumber = cardNumberField.text?.replacingOccurrences(of: " ", with: "") ?? ""
        viewModel.expirationMonth = expirationMonthField.text ?? ""
        viewModel.expirationYear = expirationYearField.text ?? ""
        viewModel.cvv = cvvField.text ?? ""
        
        viewModel.confirmPayment()
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Pago exitoso", message: "Gracias por tu compra.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
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
            guard let text = textField.text,
                  let formatted = viewModel.formatCardNumber(text, range: range, replacement: string) else {
                return false
            }
            textField.text = formatted
            return false
        }

        let maxLengths: [UITextField: Int] = [
            expirationMonthField: 2,
            expirationYearField: 2,
            cvvField: 3
        ]

        if let maxLength = maxLengths[textField],
           let currentText = textField.text,
           let stringRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= maxLength
        }

        return true
    }
}

