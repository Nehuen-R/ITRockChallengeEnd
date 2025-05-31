//
//  CountrySelectorViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import Foundation
import CoreData

class CountrySelectorViewModel: ObservableObject {
    @Published private var selectedCountry: Country?
}
