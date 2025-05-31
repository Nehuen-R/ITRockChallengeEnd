//
//  CountrySelectorView.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 28/05/2025.
//

import UIKit
import CoreData

class CountrySelectorView: UIViewController {
    var onCountrySelected: (() -> Void)?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    @IBOutlet weak var countryA: UIButton!
    @IBOutlet weak var countryB: UIButton!
    
    @IBAction func tapCountryA(_ sender: Any) {
        GlobalViewModel.shared.saveData(context,
                                        entityName: CoreDataEntitys.persisted.rawValue,
                                        key: CoreDataEntitys.selectedCountry.rawValue,
                                        value: Country.countryA.rawValue) {
            onCountrySelected?()
        } failure: {
            
        }
    }
    
    @IBAction func tapCountryB(_ sender: Any) {
        GlobalViewModel.shared.saveData(context,
                                        entityName: CoreDataEntitys.persisted.rawValue,
                                        key: CoreDataEntitys.selectedCountry.rawValue,
                                        value: Country.countryB.rawValue) {
            onCountrySelected?()
        } failure: {
            
        }
    }
}
