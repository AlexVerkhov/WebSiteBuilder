//
//  ViewController.swift
//  WebSiteBuilder
//
//  Created by Алексей Верховых on 27.03.2022.
//

import UIKit

class WebSiteBuilderViewController: UIViewController {
    
    var websitePage: WebSitePage!
    
    @IBOutlet var webSiteScrollView: UIScrollView!
    @IBOutlet var webSiteStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = websitePage {
            if websitePage.websiteBlocks.isEmpty { websitePage.websiteBlocks = DataManager.getDemoPageBlocks() }
        } else {
            websitePage = DataManager.getDemoPage(isLong: true)
        }
        
        loadPageFromScheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollViewHeightUpdate()
    }
}

// MARK: - Adding elements
extension WebSiteBuilderViewController {
    
    private func addTextBlock(with blockType: WebSiteBlockType, and text: String) {
        let textBlock = UITextViewBlock()
        textBlock.blockType = blockType
        
        switch blockType {
        case .title: textBlock.font = FontStyle.title
        case .subtitle: textBlock.font = FontStyle.subTitle
        default: textBlock.font = FontStyle.text
        }
    
        textBlock.text = text
        textBlock.isScrollEnabled = false
        textBlock.delegate = self
        
        webSiteStackView.insertArrangedSubview(textBlock, at: webSiteStackView.subviews.count)
        scrollViewHeightUpdate()
    }
    
    private func addDivider(height: Int = 0) {
        let dividerView = UIViewDividerBlock()
        dividerView.blockType = .divider
        dividerView.alpha = 0
        dividerView.addConstraint(
            NSLayoutConstraint(
                item: dividerView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: CGFloat(height)
            )
        )
        webSiteStackView.insertArrangedSubview(dividerView, at: webSiteStackView.subviews.count)
    }
}


// MARK: - Update UI
extension WebSiteBuilderViewController {
    
    private func scrollViewHeightUpdate() {
        let newContentWidth = webSiteScrollView.bounds.width
        let newContentHeight = webSiteStackView.frame.height < webSiteScrollView.frame.height
            ? webSiteScrollView.frame.height
            : webSiteStackView.frame.height

        if webSiteScrollView.contentSize.height != newContentHeight {
            webSiteScrollView.contentSize = CGSize(width: newContentWidth, height: newContentHeight)
        }
    }
}


// MARK: - Text Field Delegate
extension WebSiteBuilderViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView is UITextViewBlock {
            scrollViewHeightUpdate()
        }
    }
}


// MARK: - Save and Load scheme
extension WebSiteBuilderViewController {
    
    private func loadPageFromScheme() {
        websitePage.websiteBlocks.forEach { websiteBlock in
            switch websiteBlock.type {
            case .title, .subtitle, .text:
                addTextBlock(with: websiteBlock.type, and: websiteBlock.text ?? "")
            default:
                // TODO: Прочие типы
                addDivider(height: websiteBlock.value ?? 0)
            }
        }
    }
    
    private func savePageToScheme() {
        var websiteBlocks: [WebSiteBlock] = []
        webSiteStackView.arrangedSubviews.forEach { webSiteBlock in
            switch webSiteBlock {
            case let textBlock as UITextViewBlock:
                websiteBlocks.append(
                    WebSiteBlock(with: textBlock.blockType,
                                 andText: textBlock.text)
                )
            case let dividerBlock as UIViewDividerBlock:
                websiteBlocks.append(
                    WebSiteBlock(with: dividerBlock.blockType,
                                 andValue: Int(dividerBlock.constraints.first?.constant ?? 0))
                )
            default:
                // TODO: Прочие типы
                print()
            }
        }
        
        websitePage.websiteBlocks = websiteBlocks
    }
}
