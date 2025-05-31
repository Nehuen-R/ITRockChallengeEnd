//
//  ProductRowViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 31/05/2025.
//

import SwiftUI
import Combine

class ProductRowViewModel: ObservableObject {
    @Published var downloadedImage: UIImage? = nil
    @Published var compressedImage: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    
    let product: ProductProtocol
    
    var title: String { product.title }
    var priceText: String { product.priceText }
    var codeQRText: String { "\(product.country?.rawValue ?? ""):\(product.id)" }
    var imageUrlString: String { product.image }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(product: ProductProtocol) {
        self.product = product
        loadImage(from: product.image)
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            hasError = true
            isLoading = false
            return
        }
        isLoading = true
        hasError = false
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(_):
                    self.hasError = true
                    self.isLoading = false
                case .finished:
                    break
                }
            } receiveValue: { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.downloadedImage = image
                    self.compress(image)
                } else {
                    self.hasError = true
                }
                self.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func compress(_ image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let resized = image.resized(maxSize: 500),
                  let compressedData = resized.compressed(quality: 0.5),
                  let compressedUIImage = UIImage(data: compressedData) else {
                DispatchQueue.main.async {
                    self.hasError = true
                }
                return
            }
            DispatchQueue.main.async {
                self.compressedImage = compressedUIImage
            }
        }
    }
}
