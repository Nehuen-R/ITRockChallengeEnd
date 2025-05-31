//
//  UIViewControllerWrapper.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 29/05/2025.
//

import SwiftUI
import UIKit

struct UIViewControllerWrapper<Controller: UIViewController>: UIViewControllerRepresentable {
    let storyboardName: String?
    let identifier: String?
    let configure: (Controller) -> Void

    func makeUIViewController(context: Context) -> Controller {
        let controller: Controller

        if let storyboardName = storyboardName, let identifier = identifier {
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? Controller else {
                fatalError("Controller with ID \(identifier) not found in \(storyboardName)")
            }
            controller = vc
        } else {
            controller = Controller()
        }

        configure(controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) { }
}
