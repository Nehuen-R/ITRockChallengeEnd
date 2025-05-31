//
//  Image+Extensions.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 30/05/2025.
//

import SwiftUI

extension Image {
    func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self.resizable())
        let view = controller.view

        let targetSize = CGSize(width: 200, height: 200)
        view?.bounds = CGRect(origin: .zero, size: targetSize)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}
