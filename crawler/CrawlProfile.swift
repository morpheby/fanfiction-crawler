//
//  CrawlProfile.swift
//  Crawler
//
//  Created by Ilya Mikhaltsou on 6/17/17.
//
//

import Foundation
import Kanna
import Regex

func crawlProfile(profile: Profile, repository repo: Repository) throws -> [CrawlableObject] {
    let profileUrl = profile.objectUrl
    
    guard !profile.objectIsCrawled else {
        return []
    }
    
    let data = try String(contentsOf: profileUrl)
    var crawlables: [CrawlableObject] = []

    guard let html = Kanna.HTML(html: data, encoding: .utf8) else {
        throw CrawlError(url: profileUrl, info: "Unable to parse HTML")
    }

    let name = (html.xpath("//div[@id='content_wrapper_inner']/span").first?.text?
        .trimmingCharacters(in: .whitespacesAndNewlines))!

    let bio = html.xpath("//div[@id='bio']").first?.text

    let favoritedStories: [Book] = {
        return html.xpath("//div[@id='fs']/div[@id='fs_inside']/div/a[@class='stitle']/@href")
            .flatMap { x in x.text }
            .flatMap { s in URL(string: s, relativeTo: baseUrl) }
            .flatMap { u in
                let b = repo.getBook(forUrl: u)
                if !b.objectIsCrawled {
                    crawlables.append(b)
                }
                return b
        }
    }()

    let stories: [Book] = {
        return html.xpath("//div[@id='st']/div[@id='st_inside']/div/a[@class='stitle']/@href")
            .flatMap { x in x.text }
            .flatMap { s in URL(string: s, relativeTo: baseUrl) }
            .flatMap { u in
                let b = repo.getBook(forUrl: u)
                if !b.objectIsCrawled {
                    crawlables.append(b)
                }
                return b
        }
    }()


    let authors: [Profile] = {
        return html.xpath("//div[@id='fa']/table/tr/td//a/@href")
            .flatMap { x in x.text }
            .flatMap { s in URL(string: s, relativeTo: baseUrl) }
            .flatMap { u in
                let b = repo.getAuthor(forUrl: u)
                if !b.objectIsCrawled {
                    crawlables.append(b)
                }
                return b
        }
    }()
    
    repo.perform {
        profile.name = name
        profile.bio = bio
        profile.favBooks = Set(favoritedStories) as NSSet
        profile.favAuthors = Set(authors) as NSSet
        profile.authorOf = Set(stories) as NSSet
        
        profile.objectIsCrawled = true
    }
    
    return crawlables
}
