//
//  Style.swift
//  WebSiteBuilder
//
//  Created by Алексей Верховых on 27.03.2022.
//

import UIKit

struct FontStyle {
    static var title: UIFont {
        guard let font = UIFont(name: "HelveticaNeue-Bold", size: 24) else { fatalError("Failed to load the font") }
        return font
    }
    
    static var subTitle: UIFont? {
        guard let font = UIFont(name: "HelveticaNeue-Bold", size: 18) else { fatalError("Failed to load the font") }
        return font
    }
    
    static var text: UIFont? {
        guard let font = UIFont(name: "HelveticaNeue", size: 14) else { fatalError("Failed to load the font") }
        return font
    }
}
