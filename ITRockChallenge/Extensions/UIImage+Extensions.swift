//
//  UIImage+Extensions.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 30/05/2025.
//

import UIKit

extension UIImage {
    func resized(maxSize: CGFloat) -> UIImage? {
        let maxDimension = max(size.width, size.height)
        guard maxDimension > maxSize else { return self }

        let scale = maxSize / maxDimension
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    func compressed(quality: CGFloat = 0.7) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
}
