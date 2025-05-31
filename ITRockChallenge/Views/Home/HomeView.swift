//
//  HomeView.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasSelectedCountry {
                    Group {
                        if viewModel.fetchingData {
                            ProgressView()
                                .foregroundStyle(.black)
                                .tint(.black)
                        } else {
                            VStack {
                                Toggle(isOn: $viewModel.showCodeForQR) {
                                    Text("Show code for QR")
                                }
                                .padding()
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 12) {
                                        ForEach(viewModel.products, id: \.id) { product in
                                            Button(action:{
                                                viewModel.detailSelected = product
                                                viewModel.navigationDestination = AnyView(
                                                    UIViewControllerWrapper(storyboardName: "ProductDetail",
                                                                            identifier: "ProductDetailView") {
                                                                                (controller: ProductDetailView) in
                                                                                if let selectedDetail = viewModel.detailSelected {
                                                                                    controller.productSelected = selectedDetail
                                                                                }
                                                                            })
                                                viewModel.navigationPresented = true
                                            }){
                                                ProductRow(product: product, showCodeForQR: $viewModel.showCodeForQR)
                                                    .onAppear {
                                                        viewModel.loadMoreProductsIfNeeded(currentProduct: product)
                                                    }
                                            }
                                        }
                                        
                                        if viewModel.products.count < viewModel.allProducts.count {
                                            ProgressView()
                                                .padding()
                                        }
                                    }
                                }
                            }
                            .safeAreaInset(edge: .bottom) {
                                HStack {
                                    Button(action:{
                                        viewModel.hasSelectedCountry = false
                                    }){
                                        Text(viewModel.selectedCountry?.rawValue ?? "")
                                    }
                                    .padding()
                                    
                                    Button(action:{
                                        viewModel.navigationDestination = AnyView(
                                            UIViewControllerWrapper(storyboardName: nil,
                                                                    identifier: "QRScannerView",
                                                                    configure: { (controller: QRScannerView) in
                                                                        controller.onProductDetected = { qrValue in
                                                                            viewModel.processQR(context, qrValue: qrValue)
                                                                        }
                                                                    }))
                                        viewModel.navigationPresented = true
                                    }){
                                        Image(systemName: "qrcode.viewfinder")
                                    }
                                    .padding()
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                }
                            }
                        }
                    }
                    .onAppear {
                        viewModel.fetchData()
                    }
                } else {
                    UIViewControllerWrapper(storyboardName: "CountrySelector",
                                            identifier: "CountrySelectorView") { (controller: CountrySelectorView) in
                        controller.onCountrySelected = {
                            viewModel.loadData(context)
                        }
                    }
                }
            }
            .onAppear {
                if viewModel.idForQR == nil {
                    viewModel.loadData(context)
                }
            }
            .navigationDestination(isPresented: $viewModel.navigationPresented) {
                viewModel.navigationDestination
            }
        }
    }
}

