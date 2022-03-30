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
    var domain: String
    var url: String
    var title: String
    var description: String
    var keywords: String
    var name: String
    var websiteBlocks: [WebSiteBlock]
}

struct WebSiteBlock {
    let type: WebSiteBlockType
    let image: String?
    var text: String?
    var value: Int?
}

// MARK: - WebsiteBlock Init
extension WebSiteBlock {
    
    init(with blockType: WebSiteBlockType, andText text: String) {
        self.text = text
        type = blockType
        image = nil
        value = nil
    }
    
    init(with blockType: WebSiteBlockType, andImage image: String) {
        self.image = image
        type = blockType
        text = nil
        value = nil
    }
    
    init(with blockType: WebSiteBlockType, andValue value: Int) {
        self.value = value
        type = blockType
        image = nil
        text = nil
    }
}

// MARK: - Enums
enum WebSiteBlockType {
    case title
    case subtitle
    case text
    case image
    case imageGallery
    case form
    case footer
    case divider
}

enum DefaultTextFor: String {
    case title = "Заголовок"
    case subtitle = "Отредактируйте подзаголовок вашего сайта"
    case text = "Разместите здесь описание вашего продукта или услуги. Вы можете отредактировать этот текст - просто нажмите на него"
}

struct WebSiteConstants {
    static let blockHeightDefault = 50
}
