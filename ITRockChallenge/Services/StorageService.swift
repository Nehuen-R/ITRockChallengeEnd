//
//  GlobalViewModel.swift
//  ITRockChallenge
//
//  Created by nehuen roth on 30/05/2025.
//

import CoreData

class StorageService {
    static let shared = StorageService()

    private init() {}

    func load<T>(
        context: NSManagedObjectContext,
        entity: String,
        key: String,
        as type: T.Type
    ) -> T? {
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        let results = try? context.fetch(request)
        return results?.first?.value(forKey: key) as? T
    }

    func save<T>(
        context: NSManagedObjectContext,
        entity: String,
        key: String,
        value: T
    ) {
        let request = NSFetchRequest<NSManagedObject>(entityName: entity)
        let results = try? context.fetch(request)
        let object = results?.first ?? {
            let entityDesc = NSEntityDescription.entity(forEntityName: entity, in: context)!
            return NSManagedObject(entity: entityDesc, insertInto: context)
        }()
        object.setValue(value, forKey: key)
        try? context.save()
    }
}
