//
//  Products.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import Foundation

protocol ProductProtocol {
    var id: Int { get }
    var title: String { get }
    var price: Double { get }
    var description: String { get }
    var priceText: String { get }
    var image: String { get }
    var country: Country? { get set }
    var isFeatured: Bool? { get set }
}

struct ProductA: Decodable, ProductProtocol {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
    var priceText: String { "$\(price)"}
    var country: Country?
    var isFeatured: Bool?
}

struct Rating: Decodable {
    let rate: Double
    let count: Int
}

struct ProductB: Decodable, ProductProtocol {
    let id: Int
    let title: String
    let slug: String
    let price: Double
    let description: String
    let category: Category
    let images: [String]
    var priceText: String { "$\(price)"}
    var image: String { images.first ?? "" }
    var country: Country?
    var isFeatured: Bool?
}

struct Category: Decodable {
    let id: Int
    let name: String
}
