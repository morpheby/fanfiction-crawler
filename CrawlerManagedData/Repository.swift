//
//  Repository.swift
//  Crawler
//
//  Created by Ilya Mikhaltsou on 6/16/17.
//
//

import Foundation
import CoreData

public class Repository {
    let persistentContainer: NSPersistentContainer
    var backgroundContext: NSManagedObjectContext!

    public init() {
        print("Loading store")
        
        let model = NSManagedObjectModel(contentsOf: Bundle(for: Repository.self)
            .url(forResource: "Model", withExtension: "momd")!)!
        persistentContainer = NSPersistentContainer(name: "Model_2", managedObjectModel: model)
        if persistentContainer.managedObjectModel.entitiesByName.index(forKey: "Book") == nil {
            fatalError("Invalid Core Data model")
        }
        persistentContainer.persistentStoreDescriptions[0].shouldMigrateStoreAutomatically = true
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            if let s = description.url?.absoluteString {
                print(s)
            }
            self.backgroundContext = self.persistentContainer.newBackgroundContext()
        }
        
    }
    
    func readAllObjects<T: NSManagedObject>(_: T.Type) -> [T] {
        let request: NSFetchRequest = T.fetchRequest()
        return (try? self.backgroundContext.fetch(request).flatMap { x in x as? T }) ?? []
    }

    public func purge() {
        readAllObjects(Book.self).forEach { x in backgroundContext.delete(x) }
        readAllObjects(Profile.self).forEach { x in backgroundContext.delete(x) }
        readAllObjects(Review.self).forEach { x in backgroundContext.delete(x) }

        save()
    }
    
    public func save() {
        self.backgroundContext.performAndWait {
            do {
                try self.backgroundContext.save()
            }
            catch let e {
                fatalError("Error committing: \(e) ")
            }
        }
    }
    
    func newObject<T: NSManagedObject>(type: T.Type) -> T {
        return T(context: self.backgroundContext)
    }

    func existingObject<T: NSManagedObject>(forUrlStr url: String, type: T.Type) -> T? where T: CrawlableObject {
        let request: NSFetchRequest = T.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [url])
        return (try? self.backgroundContext.fetch(request).flatMap { x in x as? T })?.first
    }
    
    func newObject<T: NSManagedObject>(forUrlStr url: String, type: T.Type) -> T where T: CrawlableObject {
        let o = self.newObject(type:T.self)
        o.setValue(url, forKey: "id")
        return o
    }
    
    func readAllObjects<T: NSManagedObject>(_: T.Type, withPredicate predicate: NSPredicate) -> [T] {
        let request: NSFetchRequest = T.fetchRequest()
        request.predicate = predicate
        return (try? self.backgroundContext.fetch(request).flatMap { x in x as? T }) ?? []
    }
    
}

extension Repository {

    public func getAuthor(forUrl url: URL) -> Profile {
        var result: Profile?
        self.backgroundContext.performAndWait {
            result = self.existingObject(forUrlStr: url.absoluteString, type: Profile.self) ??
                self.newObject(forUrlStr: url.absoluteString, type: Profile.self)
        }
        return result!
    }

    public func getBook(forUrl url: URL) -> Book {
        var result: Book?
        self.backgroundContext.performAndWait {
            result = self.existingObject(forUrlStr: url.absoluteString, type: Book.self) ??
                self.newObject(forUrlStr: url.absoluteString, type: Book.self)
        }
        return result!
    }
    
    public func findBook(forUrl url: URL) -> Book? {
        var result: Book?
        self.backgroundContext.performAndWait {
            result = self.existingObject(forUrlStr: url.absoluteString, type: Book.self)
        }
        return result
    }
    
    public func newBook(forUrl url: URL) -> Book {
        var result: Book?
        self.backgroundContext.performAndWait {
            result = self.newObject(forUrlStr: url.absoluteString, type: Book.self)
        }
        return result!
    }
    
    public func getReviewPage(forUrl url: URL) -> ReviewPage {
        var result: ReviewPage?
        self.backgroundContext.performAndWait {
            result = self.existingObject(forUrlStr: url.absoluteString, type: ReviewPage.self) ??
                self.newObject(forUrlStr: url.absoluteString, type: ReviewPage.self)
        }
        return result!
    }
    
    public func newReview() -> Review {
        var result: Review?
        self.backgroundContext.performAndWait {
            result = self.newObject(type: Review.self)
        }
        return result!
    }
    
    public func allBooks() -> [Book] {
        var result: [Book]?
        self.backgroundContext.performAndWait {
            result = self.readAllObjects(Book.self)
        }
        return result!
    }
    public func allReviewPages() -> [ReviewPage] {
        var result: [ReviewPage]?
        self.backgroundContext.performAndWait {
            result = self.readAllObjects(ReviewPage.self)
        }
        return result!
    }
    public func allReviews() -> [Review] {
        var result: [Review]?
        self.backgroundContext.performAndWait {
            result = self.readAllObjects(Review.self)
        }
        return result!
    }
    public func allProfiles() -> [Profile] {
        var result: [Profile]?
        self.backgroundContext.performAndWait {
            result = self.readAllObjects(Profile.self)
        }
        return result!
    }
    
    public func allUncrawledBooks() -> [Book] {
        var result: [Book]?
        self.backgroundContext.performAndWait {
            result = self.readAllObjects(Book.self, withPredicate: NSPredicate(format: "obj_deleted == TRUE",
                                                                               argumentArray: []))
        }
        return result!
    }
    public func allUncrawledReviewPages() -> [ReviewPage] {
        var result: [ReviewPage]?
        self.backgroundContext.performAndWait {
            result = self.readAllObjects(ReviewPage.self, withPredicate: NSPredicate(format: "obj_deleted == TRUE",
                                                                                     argumentArray: []))
        }
        return result!
    }
    public func allUncrawledProfiles() -> [Profile] {
        var result: [Profile]?
        self.backgroundContext.performAndWait {
            result = self.readAllObjects(Profile.self, withPredicate: NSPredicate(format: "obj_deleted == TRUE",
                                                                                  argumentArray: []))
        }
        return result!
    }
    
    public func perform(block: @escaping () -> (Void)) {
        self.backgroundContext.perform(block)
    }
}

