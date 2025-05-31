//
//  ProductRow.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 30/05/2025.
//

import SwiftUI

struct ProductRow: View {
    let product: ProductProtocol
    @Binding var showCodeForQR: Bool
    
    @State private var compressedImage: UIImage?

    var body: some View {
        VStack(alignment: .leading) {
            if showCodeForQR {
                Text("\(product.country?.rawValue ?? ""):\(product.id)")
                    .foregroundColor(.primary)
            }
            HStack(alignment: .center) {
                if let uiImage = compressedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipped()
                } else {
                    AsyncImage(url: URL(string: product.image)) { phase in
                        if let image = phase.image {
                            Color.clear
                                .frame(width: 80, height: 80)
                                .onAppear {
                                    DispatchQueue.main.async {
                                        let image = image.asUIImage()
                                        DispatchQueue.global(qos: .userInitiated).async {
                                            if let compressed = compressImage(image, compressionQuality: 0.5) {
                                                DispatchQueue.main.async {
                                                    self.compressedImage = compressed
                                                }
                                            }
                                        }
                                    }
                                }
                        } else if phase.error != nil {
                            Image(systemName: "xmark.octagon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.red)
                        } else {
                            ProgressView()
                                .frame(width: 80, height: 80)
                                .redacted(reason: .placeholder)
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Text(product.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    Text(product.priceText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
        .padding()
    }
    
    func compressImage(_ image: UIImage, compressionQuality: CGFloat = 0.5) -> UIImage? {
        guard let jpegData = image.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        return UIImage(data: jpegData)
    }
}

