//
//  ProductDetailViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import Foundation
import UIKit

class ProductDetailViewModel {
    let product: ProductProtocol
    
    var titleText: String {
        product.title
    }
    
    var descriptionText: String {
        product.description
    }
    
    var categoryText: String? {
        if let productB = product as? ProductB {
            return productB.category.name
        }
        return nil
    }
    
    var ratingText: NSAttributedString? {
        guard let productA = product as? ProductA else { return nil }

        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "star.fill")?.withTintColor(.systemYellow)
        attachment.bounds = CGRect(x: 0, y: -4, width: 22, height: 22)

        let attachmentString = NSAttributedString(attachment: attachment)
        let ratingString = NSMutableAttributedString(string: " ")
        ratingString.append(attachmentString)
        ratingString.append(NSAttributedString(string: " \(productA.rating.rate) (\(productA.rating.count) reviews)"))
        return ratingString
    }
    
    var shouldShowRating: Bool {
        product is ProductA
    }
    
    var shouldShowCategory: Bool {
        product is ProductB
    }
    
    var imageURL: URL? {
        URL(string: product.image)
    }
    
    init(product: ProductProtocol) {
        self.product = product
    }
}

