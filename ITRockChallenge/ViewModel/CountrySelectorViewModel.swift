//
//  CountrySelectorViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import Foundation
import CoreData

class CountrySelectorViewModel {
    private let context: NSManagedObjectContext

    var onSuccess: (() -> Void)?
    var onFailure: (() -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func selectCountry(_ country: Country) {
        GlobalViewModel.shared.saveData(
            context,
            entityName: CoreDataEntitys.persisted.rawValue,
            key: CoreDataEntitys.selectedCountry.rawValue,
            value: country.rawValue
        ) { [weak self] in
            self?.onSuccess?()
        } failure: { [weak self] in
            self?.onFailure?()
        }
    }
}
