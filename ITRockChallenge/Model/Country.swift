//
//  Country.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 30/05/2025.
//

enum Country: String, Codable, CaseIterable {
    case countryA = "countrya"
    case countryB = "countryb"

    var displayName: String {
        switch self {
        case .countryA: return "Country A"
        case .countryB: return "Country B"
        }
    }
}
