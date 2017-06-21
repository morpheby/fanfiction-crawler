//
//  Book+CoreDataClass.swift
//  Crawler
//
//  Created by Ilya Mikhaltsou on 6/16/17.
//
//

import Foundation
import CoreData

@objc(Book)
public class Book: NSManagedObject {
    var characters: [String] {
        get {
            return self.charactersString?.components(separatedBy: "|") ?? []
        }
        set {
            self.charactersString = newValue.joined(separator: "|")
        }
    }
    
    var chapters: Int? {
        get {
            return self.chaptersInt == -1 ? nil : Int(self.chaptersInt)
        }
        set {
            self.chaptersInt = newValue.flatMap { Int32($0) } ?? -1
        }
    }
    
    var words: Int? {
        get {
            return self.wordsInt == -1 ? nil : Int(self.wordsInt)
        }
        set {
            self.wordsInt = newValue.flatMap { Int32($0) } ?? -1
        }
    }
    
    var favs: Int? {
        get {
            return self.favsInt == -1 ? nil : Int(self.favsInt)
        }
        set {
            self.favsInt = newValue.flatMap { Int32($0) } ?? -1
        }
    }
    
    var follows: Int? {
        get {
            return self.followsInt == -1 ? nil : Int(self.followsInt)
        }
        set {
            self.followsInt = newValue.flatMap { Int32($0) } ?? -1
        }
    }
    
    var lastUpdate: Date? {
        get {
            return self.lastUpdateDate as Date?
        }
        set {
            self.lastUpdateDate = newValue.flatMap { x in x as NSDate }
        }
    }
    
    var published: Date? {
        get {
            return self.publishedDate as Date?
        }
        set {
            self.publishedDate = newValue.flatMap { x in x as NSDate }
        }
    }
}
