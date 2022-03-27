//
//  WebSite.swift
//  WebSiteBuilder
//
//  Created by Алексей Верховых on 27.03.2022.
//

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
    var websiteBlocks: [WebSiteBlock]
}

struct WebSiteBlock {
    let type: WebSiteBlockType
    let image: String?
    var text: String?
}

enum WebSiteBlockType {
    case title
    case text
    case image
    case imageGallery
    case form
    case footer
}
