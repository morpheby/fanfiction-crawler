//
//  CoreData+CrawlableObject.swift
//  Crawler
//
//  Created by Анастасия Василевская on 6/18/17.
//
//

import Foundation

extension Book: CrawlableObject {
    var objectUrl: URL {
        get {
            return URL(string: self.id!)!
        }
    }
    
    var objectIsCrawled: Bool {
        get {
            return !self.obj_deleted
        }
        set {
            self.obj_deleted = !newValue
        }
    }
}

extension Profile: CrawlableObject {
    var objectUrl: URL {
        get {
            return URL(string: self.id!)!
        }
    }
    
    var objectIsCrawled: Bool {
        get {
            return !self.obj_deleted
        }
        set {
            self.obj_deleted = !newValue
        }
    }
}

extension ReviewPage: CrawlableObject {
    var objectUrl: URL {
        get {
            return URL(string: self.id!)!
        }
    }
    
    var objectIsCrawled: Bool {
        get {
            return !self.obj_deleted
        }
        set {
            self.obj_deleted = !newValue
        }
    }
}
