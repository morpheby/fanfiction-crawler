//
//  Review+CoreDataClass.swift
//  Crawler
//
//  Created by Ilya Mikhaltsou on 6/16/17.
//
//

import Foundation
import CoreData

@objc(Review)
public class Review: NSManagedObject {
    var chapter: Int? {
        get {
            return self.chapterInt == -1 ? nil : Int(self.chapterInt)
        }
        set {
            self.chapterInt = newValue.flatMap { Int32($0) } ?? -1
        }
    }
    
    var dateWritten: Date? {
        get {
            return self.dateWrittenDate as Date?
        }
        set {
            self.dateWrittenDate = newValue.flatMap { x in x as NSDate }
        }
    }
}
