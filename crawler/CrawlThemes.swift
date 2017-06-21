//
//  CrawlThemes.swift
//  CrossroadRegex
//
//  Created by Ilya Mikhaltsou on 6/16/17.
//
//

import Foundation
import Kanna
import Regex

func crawlThemes(url: URL, repository repo: Repository) throws -> [URL] {
    let data = try String(contentsOf: url)

    guard let html = Kanna.HTML(html: data, encoding: .utf8) else {
        throw CrawlError(url: url, info: "Unable to parse HTML")
    }

    return html.xpath("//div[@id='list_output']/table/tr/td/div/a/@href").flatMap { x in
        x.text.flatMap { baseUrl.appendingPathComponent($0) }
    }
}
