//
//  ProductDetailView.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import UIKit

class ProductDetailView: UIViewController {
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailDescription: UILabel!
    @IBOutlet weak var detailCategory: UILabel!
    @IBOutlet weak var detailRating: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var purchaseButton: UIButton!
    
    var viewModel: ProductDetailViewModel!
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           detailTitle.text = viewModel.titleText
           detailDescription.text = viewModel.descriptionText
           
           detailCategory.isHidden = !viewModel.shouldShowCategory
           detailCategory.text = viewModel.categoryText
           
           detailRating.isHidden = !viewModel.shouldShowRating
           detailRating.attributedText = viewModel.ratingText
           
           if let url = viewModel.imageURL {
               URLSession.shared.dataTask(with: url) { data, _, error in
                   DispatchQueue.main.async {
                       if let data = data, let image = UIImage(data: data), error == nil {
                           self.detailImage.image = image
                       } else {
                           self.detailImage.image = UIImage(systemName: "xmark.octagon")
                           self.detailImage.tintColor = .red
                       }
                   }
               }.resume()
           } else {
               detailImage.image = UIImage(systemName: "xmark.octagon")
               detailImage.tintColor = .red
           }
           
           purchaseButton.setTitle("Comprar", for: .normal)
           purchaseButton.layer.cornerRadius = 10
           
           [detailTitle, detailDescription, detailCategory, detailRating, detailImage, purchaseButton].forEach {
               $0?.backgroundColor = .gray.withAlphaComponent(0.25)
               $0?.layer.cornerRadius = 20
               $0?.layer.masksToBounds = true
           }
       }
       
       @IBAction func paymentTapped(_ sender: Any) {
           let storyboard = UIStoryboard(name: "Payment", bundle: nil)
           if let paymentV = storyboard.instantiateViewController(withIdentifier: "PaymentView") as? PaymentView {
               paymentV.product = viewModel.product
               navigationController?.pushViewController(paymentV, animated: true)
           }
       }
}
