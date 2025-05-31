//
//  NavigationDestination.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 31/05/2025.
//

import CoreData

enum NavigationDestination {
    case qrScanner(context: NSManagedObjectContext)
    case productDetail
    case countrySelector(context: NSManagedObjectContext)
}
