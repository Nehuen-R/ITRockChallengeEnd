//
//  QRScannerViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import Foundation
import Combine

class QRScannerViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isScanningActive: Bool = true
    @Published var country: Country?
    @Published var id: Int?
    
    var onProductDetected: ((Country?, Int?) -> Void)?

    func handleScannedQR(_ qrValue: String) {
        if let (country, id) = validateQR(qrValue) {
            isScanningActive = false
            onProductDetected?(country, id)
        } else {
            isScanningActive = true
            errorMessage = ErrorLogger.invalidQR.rawValue
        }
    }
    
    func validateQR(_ qrValue: String) -> (Country, Int)? {
        let components = qrValue.split(separator: ":").map { String($0.lowercased()) }
        guard components.count == 2,
              let country = Country(rawValue: components[0]),
              let id = Int(components[1]) else {
            return nil
        }
        return (country, id)
    }

    func resetScanner() {
        errorMessage = nil
        country = nil
        id = nil
        isScanningActive = true
    }
}
