//
//  HomeViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import Foundation
import CoreData
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var selectedCountry: Country?
    @Published var hasSelectedCountry = false
    @Published var fetchingData = false

    @Published var detailSelected: ProductProtocol?
    
    @Published var navigationDestination: AnyView = AnyView(EmptyView())
    @Published var navigationPresented = false

    @Published var errorMessage: String?

    @Published var showCodeForQR = false
    @Published var idForQR: Int?

    @Published var products: [any ProductProtocol] = []
    @Published var allProducts: [any ProductProtocol] = []
    private var currentPage = 0
    private let pageSize = 7

    private var cancellables = Set<AnyCancellable>()

    private let storageService: StorageService
    private let productRepository: ProductRepository

    init(storageService: StorageService = StorageService.shared,
         productRepository: ProductRepository = ProductRepository()) {
        self.storageService = storageService
        self.productRepository = productRepository
    }
    
    func fetchData() {
        guard let country = selectedCountry else { return }
        fetchingData = true

        productRepository.fetchProducts(for: country)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.fetchingData = false
                switch completion {
                case .finished:
                    self.errorMessage = nil
                    self.sendDetail()
                case .failure:
                    self.errorMessage = ErrorLogger.notFoundedProducts.rawValue
                }
            } receiveValue: { products in
                self.resetPagination(with: products)
            }
            .store(in: &cancellables)
    }
    
    func loadData(_ context: NSManagedObjectContext) {
        if let countryRaw = storageService.load(context: context,
                                                entity: CoreDataEntitys.persisted.rawValue,
                                                key: CoreDataEntitys.selectedCountry.rawValue,
                                                as: String.self),
           let country = Country(rawValue: countryRaw) {
            selectedCountry = country
            hasSelectedCountry = true
        } else {
            hasSelectedCountry = false
        }
    }
    
    func processQR(_ context: NSManagedObjectContext, country: Country, id: Int) {
        navigationPresented = false
        fetchingData = true

        idForQR = id
        selectedCountry = country

        storageService.save(context: context,
                            entity: CoreDataEntitys.persisted.rawValue,
                            key: CoreDataEntitys.selectedCountry.rawValue,
                            value: country.rawValue)

        loadData(context)
        fetchData()
    }
    
    func sendDetail() {
        guard let id = idForQR else { return }

        detailSelected = products.first(where: { $0.id == id })

        if let product = detailSelected {
            navigationDestination = AnyView(
                UIViewControllerWrapper(storyboardName: "ProductDetail",
                                        identifier: "ProductDetailView") { controller in
                    (controller as? ProductDetailView)?.viewModel = ProductDetailViewModel(product: product)
                })
            navigationPresented = true
        } else {
            self.errorMessage = ErrorLogger.notFoundedProduct.rawValue
        }

        idForQR = nil
    }
    
    func loadMoreProductsIfNeeded(currentProduct: ProductProtocol) {
        guard let index = products.firstIndex(where: { $0.id == currentProduct.id }) else { return }

        let thresholdIndex = products.count - 2
        if index >= thresholdIndex {
            loadNextPage()
        }
    }

    func loadNextPage() {
        let start = currentPage * pageSize
        let end = min(start + pageSize, allProducts.count)
        guard start < end else { return }

        products.append(contentsOf: allProducts[start..<end])
        currentPage += 1
    }

    func resetPagination(with data: [any ProductProtocol]) {
        allProducts = data
        products = []
        currentPage = 0
        loadNextPage()
    }
    
    @ViewBuilder
    func makeWrapper(for destination: NavigationDestination) -> some View {
        switch destination {
        case let .qrScanner(context):
            UIViewControllerWrapper(storyboardName: nil, identifier: "QRScannerView") { (controller: QRScannerView) in
                controller.viewModel.onProductDetected = { country, id in
                    guard let country = country, let id = id else { return }
                    self.processQR(context, country: country, id: id)
                }
            }

        case .productDetail:
            UIViewControllerWrapper(storyboardName: "ProductDetail", identifier: "ProductDetailView") { (controller: ProductDetailView) in
                if let selected = self.detailSelected {
                    controller.viewModel = ProductDetailViewModel(product: selected)
                }
            }

        case let .countrySelector(context):
            UIViewControllerWrapper(storyboardName: "CountrySelector", identifier: "CountrySelectorView") { (controller: CountrySelectorView) in
                controller.onCountrySelected = {
                    self.loadData(context)
                }
            }
        }
    }
}
