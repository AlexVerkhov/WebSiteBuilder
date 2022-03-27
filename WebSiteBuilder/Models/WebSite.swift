//
//  WebSite.swift
//  WebSiteBuilder
//
//  Created by Алексей Верховых on 27.03.2022.
//

//import Foundation

struct WebSite {
    var name: String
    var domain: String
    var pages: [WebSitePage]
}

struct WebSitePage {
    var name: String
    var url: String
    var title: String
    var description: String
    var keywords: String
    var websiteBlocks: [WebsiteBlock]
}

struct WebsiteBlock {
    let type: WebsiteBlockType
    let text: String?
    let image: String?
}

enum WebsiteBlockType {
    case title
    case text
    case image
    case imageGallery
    case form
    case footer
}
