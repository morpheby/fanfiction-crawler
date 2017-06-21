//: Please build the scheme 'CrossroadRegexPlayground' first
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = false

import Cocoa
import Kanna
import Regex
//import CrawlerManagedData
import CrawlerData
//import Crawler

let h = "Hello world"

//FileManager.default.currentDirectoryPath
//FileManager.default.changeCurrentDirectoryPath("/Users/morpheby/Downloads")
//
//var file: FileTextOutputStream = try FileTextOutputStream(fileAtPath: "output3.csv", append: false)
//
//let repo = Repository()
//
//var counter = 0
//
//for book in repo.allBooks() {
//    print("\(book.object?.title ?? ""), \(book.crawlUrl)", to: &file)
//}
//
//FileManager.default.currentDirectoryPath

let profileUrl = URL(string: "https://www.fanfiction.net/r/11248312/")!
let data = try String(contentsOf: profileUrl)
var crawlables: [Crawlable] = []

guard let html = Kanna.HTML(html: data, encoding: .utf8) else {
    abort()
}


let root = html.xpath("//div[@id='content_wrapper_inner']/div/table/tbody/tr")

