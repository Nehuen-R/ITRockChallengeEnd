//
//  ProductBannerView.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 31/05/2025.
//

import SwiftUI

struct ProductBannerView: View {
    @Binding var showCodeForQR: Bool
    @StateObject var viewModel: ProductRowViewModel
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: viewModel.product.image)) { image in
                image
                    .resizable()
                    .frame(width: 300, height: 250)
            } placeholder: {
                Image(systemName: "xmark.octagon")
                    .resizable()
                    .frame(width: 300, height: 250)
                    .foregroundStyle(.red)
            }
            .aspectRatio(contentMode: .fill)
            .clipped()

            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(viewModel.priceText)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        if showCodeForQR {
                            Text(viewModel.codeQRText)
                                .foregroundColor(.red)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.5))
            }
        }
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
