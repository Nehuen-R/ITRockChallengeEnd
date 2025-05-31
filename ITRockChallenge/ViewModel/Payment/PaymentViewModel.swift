//
//  PaymentViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import Foundation
import Combine

class PaymentViewModel {
    @Published var errorMessage: String?
    @Published var paymentSuccess: Bool = false
    
    var cardNumber = ""
    var expirationMonth = ""
    var expirationYear = ""
    var cvv = ""
    
    private let validCard = "1234567891234567"
    private let validExpiration = "12/27"
    private let validCVV = "123"

    func confirmPayment() {
        guard !cardNumber.isEmpty,
              !expirationMonth.isEmpty,
              !expirationYear.isEmpty,
              !cvv.isEmpty else {
            errorMessage = ErrorLogger.empty.rawValue
            return
        }
        
        let expiration = "\(expirationMonth)/\(expirationYear)"
        if cardNumber == validCard && expiration == validExpiration && cvv == validCVV {
            paymentSuccess = true
        } else {
            errorMessage = ErrorLogger.badPayment.rawValue
        }
    }
    
    func formatCardNumber(_ currentText: String, range: NSRange, replacement: String) -> String? {
            let allowedChars = CharacterSet.decimalDigits
            if replacement.rangeOfCharacter(from: allowedChars.inverted) != nil && !replacement.isEmpty {
                return nil
            }

            guard let stringRange = Range(range, in: currentText) else { return nil }

            let updatedText = currentText.replacingCharacters(in: stringRange, with: replacement)
            let cleanedText = updatedText.replacingOccurrences(of: " ", with: "")
            
            guard cleanedText.count <= 16 else { return nil }

            let formatted = cleanedText.enumerated().map { index, char in
                (index > 0 && index % 4 == 0) ? " \(char)" : "\(char)"
            }.joined()
            
            return formatted
        }
}
