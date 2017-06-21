//
//  dummy.swift
//  CrossroadRegex
//
//  Created by Ilya Mikhaltsou on 6/15/17.
//
//

import Foundation

var booksOutput: FileTextOutputStream = try FileTextOutputStream(fileAtPath: "books.csv", append: false)
var profilesOutput: FileTextOutputStream = try FileTextOutputStream(fileAtPath: "profiles.csv", append: false)
var reviewsOutput: FileTextOutputStream = try FileTextOutputStream(fileAtPath: "reviews.csv", append: false)

let baseUrl = URL(string: "https://www.fanfiction.net/")!
let repo = Repository()

var counter = 0

//print("Purging")
//repo.purge()

print("Starting processing")

crawler(inRepository: repo, withBaseUrl: baseUrl, themesFilter: { i in
//    return i < 40
    return false
}, pageLimit: 20,
   bookFilter: { b in return true
}, authorFilter: { b in return true
}, reviewFilter: { b in return true
}, statusCallback: { remaining, done, failed in
    if done % 100 == 0 {
        print("Commiting")
        repo.save()
    }
    print("Done: \(done), remaining: \(remaining), failed: \(failed)")
//    return done < 100000
    return true // Continue
})

repo.save()

print("Writing books")
for book in repo.allBooks() {
    print("\(book.title ?? ""), \(book.objectUrl)", to: &booksOutput)
}

print("Writing profiles")
for profile in repo.allProfiles() {
    print("\(profile.name ?? "")", to: &profilesOutput)
}

print("Writing reviews")
for review in repo.allReviews() {
    let row = [
        review.author?.name?.replacingOccurrences(of: ",", with: "\\,") ?? "",
        review.page?.book?.title?.replacingOccurrences(of: ",", with: "\\,") ?? "",
        review.text?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: ",", with: "\\,") ?? "",
    ]
    print(row.joined(separator: ","), to: &reviewsOutput)
}

print("Done. Current working directory:")
print(FileManager.default.currentDirectoryPath)
