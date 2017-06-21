//
//  CrawlReviews.swift
//  Crawler
//
//  Created by Ilya Mikhaltsou on 6/17/17.
//
//

import Foundation
import Kanna
import Regex

func crawlReviews(reviewPage: ReviewPage, repository repo: Repository) throws -> [CrawlableObject] {
    
    let reviewUrl = reviewPage.objectUrl
    
    guard !reviewPage.objectIsCrawled else {
        return []
    }
    
    repo.perform {
        reviewPage.reviews = Set<Review>() as NSSet
    }
    
    let data = try String(contentsOf: reviewUrl)
    var crawlables: [CrawlableObject] = []

    guard let html = Kanna.HTML(html: data, encoding: .utf8) else {
        throw CrawlError(url: reviewUrl, info: "Unable to parse HTML")
    }

    let lastPage: Int = {
        if let lastPageUrl = html.xpath("//div[@id='content_wrapper_inner']/center/a").filter({ x in x.text == "Last" })
            .first?.xpath("@href").first?.text,
            let lastPageNum = "/(\\d+)/$".r!.findFirst(in: lastPageUrl)?.group(at: 1),
            let value = Int(lastPageNum) {
            return value
        } else {
            return 1
        }
    }()

    let pageAdd = { (page: Int) -> String in "/0/\(page)/" }

    func crawlPage(page: Int) throws {
        let url = URL(string: reviewUrl.absoluteString + pageAdd(page))!
        let data = try String(contentsOf: url)

        guard let html = Kanna.HTML(html: data, encoding: .utf8) else {
            throw CrawlError(url: url, info: "Unable to parse HTML")
        }

        let root = html.xpath("//div[@id='content_wrapper_inner']/div/table/tbody/tr")

        for r in root {
            let author: Profile? = {
                if let urlString = r.xpath("td/a/@href").first?.text,
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

            let chapter = r.xpath("td/small").first?.text
                .flatMap { t in
                    "(\\d+)".r! .findFirst(in: t)?.group(at: 1)
            }   .flatMap { t in Int(t) }

            let text = r.xpath("td/div").first?.text

            let dateWritten: Date?
            if let dtstring = r.xpath("td/small/span/@data-xutime").first?.text,
               let time = TimeInterval(dtstring) {
                dateWritten = Date(timeIntervalSince1970: time)
            } else {
                dateWritten = nil
            }
            
            let review = repo.newReview()
            repo.perform {
                review.author = author
                review.chapter = chapter
                review.text = text
                review.dateWritten = dateWritten
                
                review.page = reviewPage
            }
        }
    }

    for i in 1...lastPage {
        try crawlPage(page: i)
    }
    
    repo.perform {
        reviewPage.objectIsCrawled = true
    }
    return crawlables
}
