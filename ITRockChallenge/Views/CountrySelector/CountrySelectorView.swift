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
    private var viewModel: CountrySelectorViewModel!

    @IBOutlet weak var countryA: UIButton!
    @IBOutlet weak var countryB: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        viewModel = CountrySelectorViewModel(context: context)
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] in
            self?.onCountrySelected?()
        }

        viewModel.onFailure = {
            
        }
    }

    @IBAction func tapCountryA(_ sender: Any) {
        viewModel.selectCountry(.countryA)
    }

    @IBAction func tapCountryB(_ sender: Any) {
        viewModel.selectCountry(.countryB)
    }
}

