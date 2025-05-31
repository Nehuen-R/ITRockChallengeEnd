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

enum Country: String, Decodable {
    case countryA = "CountryA"
    case countryB = "CountryB"
}

enum CoreDataEntitys: String {
    case persisted = "Persisted"
    case selectedCountry = "selectedCountry"
    case user = "User"
    case username = "username"
}

class GlobalViewModel: ObservableObject {
    static let shared = GlobalViewModel()
    
    func loadData<T>(
        _ context: NSManagedObjectContext,
        entityName: String,
        key: String,
        type: T.Type,
        success: (T?) -> Void,
        failure: () -> Void
    ) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)

        do {
            let results = try context.fetch(fetchRequest)
            if let first = results.first,
               let value = first.value(forKey: key) as? T {
                success(value)
            } else {
                success(nil)
            }
        } catch {
            failure()
        }
    }
    
    func saveData<T>(
        _ context: NSManagedObjectContext,
        entityName: String,
        key: String,
        value: T,
        success: () -> Void,
        failure: () -> Void
    ) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            let results = try context.fetch(fetchRequest)
            let object = results.first ?? {
                let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
                return NSManagedObject(entity: entity, insertInto: context)
            }()

            object.setValue(value, forKey: key)
            try context.save()
            success()
        } catch {
            failure()
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var selectedCountry: Country?
    @Published var hasSelectedCountry: Bool = false
    @Published var fetchingData: Bool = false
    
    @Published var detailSelected: ProductProtocol?
    @Published var navigationDestination: AnyView = AnyView(EmptyView())
    @Published var navigationPresented: Bool = false
    
    @Published var products: [any ProductProtocol] = []
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let fetcher = ProductFetcher()
    
    @Published var showCodeForQR: Bool = false
    @Published var idForQR: Int?
    
    func fetchData() {
        guard let selectedCountry else { return }
        self.fetchingData = true
        fetcher.fetchData(for: selectedCountry)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    self.fetchingData = false
                    self.sendDetail()
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { products in
                self.fetchingData = true
                self.resetPagination(with: products)
            }
            .store(in: &cancellables)

    }
    
    func loadData(_ context: NSManagedObjectContext) {
        GlobalViewModel.shared.loadData(context,
                                        entityName: CoreDataEntitys.persisted.rawValue,
                                        key: CoreDataEntitys.selectedCountry.rawValue,
                                        type: String.self) { country in
            if country != nil {
                self.selectedCountry = Country(rawValue: country ?? "")
                self.hasSelectedCountry = true
            } else {
                self.hasSelectedCountry = false
            }
        } failure: {
            self.hasSelectedCountry = false
        }
    }
    
    func processQR(_ context: NSManagedObjectContext, qrValue: String) {
        navigationPresented = false
        fetchingData = true
        
        let components = qrValue.split(separator: ":").map { String($0.lowercased()) }
        guard components.count == 2, let id = Int(components[1]) else { return }
        idForQR = id
        
        if components[0] == "countrya" {
            self.selectedCountry = .countryA
            GlobalViewModel.shared.saveData(context,
                                            entityName: CoreDataEntitys.persisted.rawValue,
                                            key: CoreDataEntitys.selectedCountry.rawValue,
                                            value: Country.countryA.rawValue) {
                self.loadData(context)
            } failure: {
                
            }
            fetchData()
        } else if components[0] == "countryb" {
            self.selectedCountry = .countryB
            GlobalViewModel.shared.saveData(context,
                                            entityName: CoreDataEntitys.persisted.rawValue,
                                            key: CoreDataEntitys.selectedCountry.rawValue,
                                            value: Country.countryB.rawValue) {
                self.loadData(context)
            } failure: {
                
            }
            fetchData()
        }
    }
    
    func sendDetail() {
        guard let idForQR else { return }
        self.detailSelected = products.first(where: { $0.id == idForQR } )
        navigationDestination = AnyView(
            UIViewControllerWrapper(storyboardName: "ProductDetail",
                                    identifier: "ProductDetailView") {
                                        (controller: ProductDetailView) in
                                        if let selectedDetail = self.detailSelected {
                                            controller.productSelected = selectedDetail
                                        }
                                    })
        navigationPresented = true
        self.idForQR = nil
    }
    
    @Published var allProducts: [any ProductProtocol] = []
    private var currentPage = 0
    private let pageSize = 7
    
    func loadMoreProductsIfNeeded(currentProduct: ProductProtocol) {
        guard let index = products.firstIndex(where: { $0.id == currentProduct.id }) else { return }

        let thresholdIndex = products.count - 2
        if index >= thresholdIndex {
            loadNextPage()
        }
    }

    func loadNextPage() {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, allProducts.count)

        guard startIndex < endIndex else { return }

        let nextPage = allProducts[startIndex..<endIndex]
        products.append(contentsOf: nextPage)
        currentPage += 1
    }

    func resetPagination(with data: [any ProductProtocol]) {
        allProducts = data
        products = []
        currentPage = 0
        loadNextPage()
    }
}

class ProductFetcher {
    private var cancellables = Set<AnyCancellable>()

    func fetchData(
        for country: Country
    ) -> AnyPublisher<[ProductProtocol], Error> {
        switch country {
        case .countryA:
            return fetchTypedData(from: "https://fakestoreapi.com/products", type: ProductA.self)
                .map { products in
                    products.map { product in
                        var p = product
                        p.country = .countryA
                        return p
                    }
                }
                .eraseToAnyPublisher()

        case .countryB:
            return fetchTypedData(from: "https://api.escuelajs.co/api/v1/products", type: ProductB.self)
                .map { products in
                    products.map { product in
                        var p = product
                        p.country = .countryB
                        return p
                    }
                }
                .eraseToAnyPublisher()
        }
    }

    private func fetchTypedData<T: Decodable>(
        from urlString: String,
        type: T.Type
    ) -> AnyPublisher<[T], Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [T].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
