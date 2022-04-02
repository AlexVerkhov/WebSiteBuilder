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
    let type: pageBlockType
    let image: String?
    var text: String?
    var value: Int?
}

// MARK: - WebsiteBlock Init
extension WebSiteBlock {
    
    init(with blockType: pageBlockType, andText text: String) {
        self.text = text
        type = blockType
        image = nil
        value = nil
    }
    
    init(with blockType: pageBlockType, andImage image: String) {
        self.image = image
        type = blockType
        text = nil
        value = nil
    }
    
    init(with blockType: pageBlockType, andValue value: Int) {
        self.value = value
        type = blockType
        image = nil
        text = nil
    }
}

// MARK: - Enums
enum pageBlockType {
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
    static let maxBlocksPerPage = 500
}

enum webPageMenuButtons: Int {
    case pageSettings = 0
    case moveDown = 1
    case addBlock = 2
    case moveUp = 3
    case blockSettings = 4
}

enum moveBlockWay {
    case up
    case down
}
