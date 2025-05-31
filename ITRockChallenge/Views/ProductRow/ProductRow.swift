//
//  ProductRow.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 30/05/2025.
//

import SwiftUI

struct ProductRow: View {
    @Binding var showCodeForQR: Bool
    @StateObject var viewModel: ProductRowViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if showCodeForQR {
                Text(viewModel.codeQRText)
                    .foregroundColor(.primary)
            }
            HStack(alignment: .center) {
                if let uiImage = viewModel.compressedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipped()
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(width: 80, height: 80)
                } else if viewModel.hasError {
                    Image(systemName: "xmark.octagon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                } else {
                    Color.clear
                        .frame(width: 80, height: 80)
                }
                
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.priceText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
        .padding()
    }
}
