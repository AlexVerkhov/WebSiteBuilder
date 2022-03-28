//
//  DataManager.swift
//  WebSiteBuilder
//
//  Created by Алексей Верховых on 28.03.2022.
//

class DataManager {
    
    static let shared = DataManager()
    // TODO: Похоже, что здесь будет храниться база данных (и публичные методы)?
    
    static func getDemoPageBlocks(isLong longFlag: Bool = false) -> [WebSiteBlock] {
        var webSiteBlocks = [
            WebSiteBlock(with: .title, andText: DefaultTextFor.title.rawValue),
            WebSiteBlock(with: .subtitle, andText: DefaultTextFor.subtitle.rawValue),
            WebSiteBlock(with: .text, andText: DefaultTextFor.text.rawValue)
        ]
        
        if longFlag {
            for _ in (1...15) {
                webSiteBlocks.append(
                    WebSiteBlock(with: .text, andText: DefaultTextFor.text.rawValue)
                )
            }
        }
        
        return webSiteBlocks
    }
    
    static func getDemoPage(isLong longFlag: Bool = false) -> WebSitePage {
        return WebSitePage(
            domain: "temp.com",
            url: "index",
            title: "Title",
            description: "Description",
            keywords: "KeyOne, KeyTwo",
            name: "User name of page",
            websiteBlocks: getDemoPageBlocks(isLong: longFlag)
        )
    }
    
    private init() {}
}
