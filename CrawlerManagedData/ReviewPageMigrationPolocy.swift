//
//  ReviewPageMigrationPolocy.swift
//  Crawler
//
//  Created by Анастасия Василевская on 6/18/17.
//
//

import Foundation
import CoreData

class ReviewPageMigrationPolocy: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let reviewUrl = sInstance.value(forKey: "url") as! String
        let oldBook = sInstance.value(forKey: "book") as! NSManagedObject
        
        let request: NSFetchRequest = ReviewPage.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", argumentArray: [reviewUrl])
        let fetchedResult = (try? manager.destinationContext.fetch(request).flatMap { x in x as? ReviewPage })?.first
        
        if let r = fetchedResult {
            r.addToReviews(manager.destinationInstances(forEntityMappingName: "ReviewToReview", sourceInstances: [sInstance]).first! as! Review)
        } else {
            let newObject = ReviewPage(context: manager.destinationContext)
            newObject.id = reviewUrl
            newObject.book = manager.destinationInstances(forEntityMappingName: "BookToBook", sourceInstances: [oldBook]).first as? Book
            
            manager.associate(sourceInstance: sInstance, withDestinationInstance: newObject, for: mapping)
        }
    }
    
}

