//
//  ProductRepository.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 30/05/2025.
//

import Combine
import Foundation

class ProductRepository {
    func fetchProducts(for country: Country) -> AnyPublisher<[ProductProtocol], Error> {
        switch country {
            case .countryA:
                return fetchTypedData(from: "https://fakestoreapi.com/products", type: ProductA.self)
                    .map { $0.map { var p = $0; p.country = .countryA; return p as ProductProtocol } }
                    .catch { error -> AnyPublisher<[ProductProtocol], Error> in
                        print("Error countryA:", error)
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()

            case .countryB:
                return fetchTypedData(from: "https://api.escuelajs.co/api/v1/products", type: ProductB.self)
                    .map { $0.map { var p = $0; p.country = .countryB; return p as ProductProtocol } }
                    .catch { error -> AnyPublisher<[ProductProtocol], Error> in
                        print("Error countryB:", error)
                        return Fail(error: error).eraseToAnyPublisher()
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
                .tryMap { result -> Data in
                    guard let httpResponse = result.response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    return result.data
                }
                .decode(type: [T].self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        }
}

