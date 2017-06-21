//
//  CrawlBooklist.swift
//  CrossroadRegex
//
//  Created by Ilya Mikhaltsou on 6/16/17.
//
//

import Foundation
import Kanna
import Regex

func crawlBooklist(listUrl: URL, repository repo: Repository, pageLimit: Int? = nil) throws -> [CrawlableObject] {
    
    let data = try String(contentsOf: listUrl)

    guard let html = Kanna.HTML(html: data, encoding: .utf8) else {
        throw CrawlError(url: listUrl, info: "Unable to parse HTML")
    }

    let lastPage: Int = pageLimit ?? {
        if let lastPageUrl = html.xpath("//div[@id='content_wrapper_inner']/center/a").filter({ x in x.text == "Last" })
            .first?.xpath("@href").first?.text,
            let lastPageNum = "p=(\\d+)".r!.findFirst(in: lastPageUrl)?.group(at: 1),
            let value = Int(lastPageNum) {
            return value
        } else {
            return 1
        }
    }()

    let pageAdd = { (page: Int) -> String in "&p=\(page)" }

    func crawlPage(page: Int) throws -> [CrawlableObject] {
        print("Page: \(page) of \(lastPage)")
        let url = URL(string: listUrl.absoluteString + pageAdd(page))!
        let data = try String(contentsOf: url)

        guard let html = Kanna.HTML(html: data, encoding: .utf8) else {
            throw CrawlError(url: url, info: "Unable to parse HTML")
        }

        let crawl: [Book] = html.xpath("//div[@id='content_wrapper_inner']/div/a[@class='stitle']/@href").flatMap { x in
            let url = baseUrl.appendingPathComponent(x.text!)
            if repo.findBook(forUrl: url) == nil {
                return repo.newBook(forUrl: url)
            } else {
                return nil
            }
        }

        return crawl
    }
    
    print("Total pages: \(lastPage)")
    return Array((1...lastPage).flatMap { (i: Int) -> [CrawlableObject]? in
        try? crawlPage(page: i)
    }.joined())
}
