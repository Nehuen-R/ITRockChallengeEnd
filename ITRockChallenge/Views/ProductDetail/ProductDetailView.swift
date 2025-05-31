//
//  ProductDetailView.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import UIKit

class ProductDetailView: UIViewController {
    var productSelected: ProductProtocol?
    
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailDescription: UILabel!
    @IBOutlet weak var detailCategory: UILabel!
    @IBOutlet weak var detailRating: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var purchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let product = productSelected else { return }

        detailTitle.text = product.title
        detailDescription.text = product.description
        
        if let productA = product as? ProductA {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "star.fill")?.withTintColor(.systemYellow)
            attachment.bounds = CGRect(x: 0, y: -4, width: 22, height: 22)

            let attachmentString = NSAttributedString(attachment: attachment)
            let ratingString = NSMutableAttributedString(string: " ")
            ratingString.append(attachmentString)
            ratingString.append(NSAttributedString(string: " \(productA.rating.rate) (\(productA.rating.count) reviews)"))

            detailRating.attributedText = ratingString
            detailCategory.isHidden = true
        }
        
        if let productB = product as? ProductB {
            detailCategory.text = productB.category.name
            detailRating.isHidden = true
        }
        
        if let url = URL(string: product.image) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async {
                    if let data = data, error == nil, let image = UIImage(data: data) {
                        self.detailImage.image = image
                    } else {
                        self.detailImage.image = UIImage(systemName: "xmark.octagon")
                        self.detailImage.tintColor = .red
                    }
                }
            }.resume()
        } else {
            self.detailImage.image = UIImage(systemName: "xmark.octagon")
            self.detailImage.tintColor = .red
        }
        
        purchaseButton.titleLabel?.text = "Comprar"
        purchaseButton.layer.cornerRadius = 10
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func paymentTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        if let paymentV = storyboard.instantiateViewController(withIdentifier: "PaymentView") as? PaymentView {
            paymentV.product = productSelected
            navigationController?.pushViewController(paymentV, animated: true)
        }
    }
}
