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
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasSelectedCountry {
                    Group {
                        ZStack {
                            if viewModel.fetchingData {
                                ProgressView()
                                    .foregroundStyle(.black)
                                    .tint(.black)
                            } else {
                                mainView
                                    .safeAreaInset(edge: .bottom) {
                                        bottomBar
                                    }
                            }
                            
                            if let errorMessage = viewModel.errorMessage {
                                errorView(errorMessage)
                            }
                        }
                    }
                    .onAppear {
                        if viewModel.errorMessage == nil && viewModel.idForQR == nil {
                            viewModel.fetchData()
                        }
                    }
                } else {
                    viewModel.makeWrapper(for: .countrySelector(context: context))
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
    
    @ViewBuilder func errorView(_ errorMessage: String) -> some View {
        ZStack {
            Rectangle()
                .fill(Material.ultraThin)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    viewModel.fetchData()
                }
                
            VStack {
                Spacer()
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .bold()
                    .padding()
                Button(action:{
                    viewModel.fetchData()
                }){
                    Text("Retry")
                        .foregroundStyle(.black)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(.gray))
                Spacer()
            }
        }
    }
    
    @ViewBuilder var mainView: some View {
        VStack {
            Toggle(isOn: $viewModel.showCodeForQR) {
                Text("Show code for QR")
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .light ? .black.opacity(0.25) : .white.opacity(0.25))
            }
            .padding()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.products, id: \.id) { product in
                        Button(action:{
                            viewModel.detailSelected = product
                            viewModel.navigationDestination = AnyView(viewModel.makeWrapper(for: .productDetail))
                            viewModel.navigationPresented = true
                        }){
                            ProductRow(showCodeForQR: $viewModel.showCodeForQR, viewModel: ProductRowViewModel(product: product))
                                .onAppear {
                                    viewModel.loadMoreProductsIfNeeded(currentProduct: product)
                                }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .light ? .black.opacity(0.25) : .white.opacity(0.25))
                        }
                        .padding(.horizontal)
                    }
                    
                    if viewModel.products.count < viewModel.allProducts.count {
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
    }
    
    @ViewBuilder var bottomBar: some View {
        HStack {
            Button(action:{
                viewModel.hasSelectedCountry = false
            }){
                Text(viewModel.selectedCountry?.displayName ?? "")
            }
            .padding()
            
            Spacer()
            
            Button(action:{
                viewModel.navigationDestination = AnyView(viewModel.makeWrapper(for: .qrScanner(context: context)))
                viewModel.navigationPresented = true
            }){
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .padding()
        }
        .foregroundStyle(colorScheme == .light ? .white : .black)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .light ? .black : .white )
        }
        .padding(.horizontal)
    }
}

