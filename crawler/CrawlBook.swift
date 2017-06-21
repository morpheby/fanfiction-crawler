//
//  CrawlBook.swift
//  CrossroadRegex
//
//  Created by Ilya Mikhaltsou on 6/16/17.
//
//

import Foundation
import Kanna
import Regex

func crawlBook(book: Book, repository repo: Repository) throws -> [CrawlableObject] {
    
    let bookUrl = book.objectUrl
    
    guard !book.objectIsCrawled else {
        return []
    }
    
    let data = try String(contentsOf: bookUrl)
    var crawlables: [CrawlableObject] = []

    guard let html = Kanna.HTML(html: data, encoding: .utf8) else {
        throw CrawlError(url: bookUrl, info: "Unable to parse HTML")
    }

    guard let id = "s/(\\d+)".r?.findFirst(in: bookUrl.absoluteString)?.group(at: 1) else {
        throw CrawlError(url: bookUrl, info: "Invalid URL")
    }

    let title = html.xpath("//div[@id='profile_top']/b").first?.text

    let author: Profile? = {
        if let urlString = html.xpath("//div[@id='profile_top']/a/@href").first?.text,
            let url = URL(string: urlString, relativeTo: baseUrl) {
            let a = repo.getAuthor(forUrl: url)
            if !a.objectIsCrawled {
                crawlables.append(a)
            }
            return a
        } else {
            return nil
        }
    }()

    let rating = html.xpath("//div[@id='profile_top']/span/a[@target='rating']").first?.text

    let metadata = Array(html.xpath("//div[@id='profile_top']/span/a[@target='rating']/..")).first?.text

    let filterInt = { (s: String) -> String in
        s.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
    }

    let language: String?
    let genre: String?
    let characters: [String]?
    let chapters: Int?
    let words: Int?
    let favs: Int?
    let follows: Int?

    if let ms = metadata?.components(separatedBy: " - ") {
        language = ms[safe: 1]
        genre = ms[safe: 2]
        characters = ms[safe: 3]?.components(separatedBy: ", ")
        if let s = ms[safe: 4]?.components(separatedBy: ":")[safe: 1] {
            chapters = Int(filterInt(s))
        } else {
            chapters = nil
        }
        if let s = ms[safe: 5]?.components(separatedBy: ":")[safe: 1] {
            words = Int(filterInt(s))
        } else {
            words = nil
        }
        if let s = ms[safe: 7]?.components(separatedBy: ":")[safe: 1] {
            favs = Int(filterInt(s))
        } else {
            favs = nil
        }
        if let s = ms[safe: 8]?.components(separatedBy: ":")[safe: 1] {
            follows = Int(filterInt(s))
        } else {
            follows = nil
        }
    } else {
        (language, genre, characters, chapters, words, favs, follows) = (nil, nil, nil, nil, nil, nil, nil)
    }

    let reviews: ReviewPage? = {
        if let urlString = Array(html.xpath("//div[@id='profile_top']/span/a/@href"))[safe: 1]?.text,
           let url = URL(string: urlString, relativeTo: baseUrl) {
            let a = repo.getReviewPage(forUrl: url)
            if !a.objectIsCrawled {
                crawlables.append(a)
            }
            return a
        } else {
            return nil
        }
    }()

    let lastUpdate: Date?
    let published: Date?

    if let dtstring = Array(html.xpath("//div[@id='profile_top']/span/span/@data-xutime"))[safe: 0]?.text,
        let time = TimeInterval(dtstring) {
        lastUpdate = Date(timeIntervalSince1970: time)
    } else {
        lastUpdate = nil
    }

    if let dtstring = Array(html.xpath("//div[@id='profile_top']/span/span/@data-xutime"))[safe: 1]?.text,
        let time = TimeInterval(dtstring) {
        published = Date(timeIntervalSince1970: time)
    } else {
        published = nil
    }

    repo.perform {
        book.bookId = id
        book.title = title
        book.author = author
        book.rating = rating
        book.language = language
        book.genre = genre
        book.characters = characters ?? []
        book.chapters = chapters
        book.words = words
        book.reviews = reviews
        book.favs = favs
        book.follows = follows
        book.lastUpdate = lastUpdate
        book.published = published
        
        book.objectIsCrawled = true
    }
    
    return crawlables
}

