//
//  DBManager.swift
//  List and Search
//
//  Created by Ömer Faruk Kazar on 4.12.2022.
//

import UIKit
import CoreData

final class DBManager {
    static let shared = DBManager() // Singleton
    
    // MARK: - Properties
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate Not Found")
        }
        return delegate
    }
    
    private var managedContext: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    // Since appDelegate and managedContext are used in more than one functions, unwrapped and shortened them as computed properties.
    
    // MARK: - CRUD Operations
    //Create
    func create(entityName: String, values: [String : Any], completion: (NSManagedObject?, Error?) -> Void) {
        let entity = NSEntityDescription.entity(forEntityName: entityName,
                                                in: managedContext)
        let object = NSManagedObject(entity: entity!, insertInto: managedContext)
        for (key, value) in values {
            object.setValue(value, forKey: key)
        }
        
        do {
            try managedContext.save()
            completion(object, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    //Read
    func read(completion: ([NSManagedObject]?, Error?) -> Void) {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        do {
            let objects = try managedContext.fetch(fetchRequest)
            completion(objects, nil)
        } catch {
            completion(nil, error)
        }
        print("read")
    }
    
    //Update
    func update() {
        print("update")
    }
    
    //Delete
    func delete(entityName: String, object: NSManagedObject, completion: (Error?) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            let tempItems = try managedContext.fetch(fetchRequest)
            for tempItem in tempItems where tempItem == object {
                managedContext.delete(tempItem)
            }
        } catch {
            print(error)
        }
        
        do {
            try managedContext.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    //DeleteAll
    func deleteAll(objects: [NSManagedObject], completion: (Error?) -> Void) {
        for object in objects {
            managedContext.delete(object)
        } // Yine objenin tüm özelliklerini karşılaştırmak yerine UUID üzerinden değiştirilebilirdi
        // TODO: Refactor'de bak
        do {
            try managedContext.save()
            completion(nil)
        } catch {
            completion(error)
        }
        
    }
    
}
