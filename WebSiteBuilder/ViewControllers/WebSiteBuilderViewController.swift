//
//  ViewController.swift
//  WebSiteBuilder
//
//  Created by Алексей Верховых on 27.03.2022.
//

import UIKit

class WebSiteBuilderViewController: UIViewController {
    
    var websitePage: WebSitePage!
    var lastTapedBlockIndex: Int = -1
    
    @IBOutlet var webSiteScrollView: UIScrollView!
    @IBOutlet var webSiteStackView: UIStackView!
    
    @IBOutlet var blockSelectorScrollView: UIScrollView!
    @IBOutlet var blockSelectorStackView: UIStackView!
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blockSelectorScrollView.isHidden = true
        blockSelectorScrollView.alpha = 0
        
        webSiteScrollView.backgroundColor = .white
        webSiteStackView.backgroundColor = .white
        
        if let _ = websitePage {
            if websitePage.websiteBlocks.isEmpty { websitePage.websiteBlocks = DataManager.getDemoPageBlocks() }
        } else {
            websitePage = DataManager.getDemoPage(isLong: false)
        }
        
        loadPageFromScheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        blockSelectorScrollView.contentSize = CGSize(width: blockSelectorStackView.frame.width, height: blockSelectorStackView.frame.height)
        
        scrollViewHeightUpdate()
        
        view.endEditing(true)
        
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
        
        let blockTap = UITapGestureRecognizer(target: self, action: #selector(setActiveBlock(_:)))
        textBlock.isUserInteractionEnabled = true
        textBlock.addGestureRecognizer(blockTap)

        webSiteStackView.insertArrangedSubview(textBlock, at: webSiteStackView.subviews.count)
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
    
    @objc private func setActiveBlock(_ sender: UITapGestureRecognizer) {
        for pageIndex in 0..<webSiteStackView.arrangedSubviews.count {
            if webSiteStackView.arrangedSubviews[pageIndex] == sender.view {
                lastTapedBlockIndex = pageIndex
                let textBlock = webSiteStackView.arrangedSubviews[pageIndex]
                
                switch textBlock {
                case is UITextViewBlock:
                    if let temp = textBlock as? UITextView {
                        temp.selectedRange = NSMakeRange(temp.text.count, 0);
                        temp.becomeFirstResponder()
                    }
                default:
                    print("default")
                }
                
            }
        }
        hideBlockSelector()
    }
}


// MARK: - Update UI
extension WebSiteBuilderViewController {
    
    private func scrollViewHeightUpdate(offset: CGFloat = 0) {
        let newContentWidth = webSiteScrollView.frame.width
        let newContentHeight = webSiteStackView.frame.height < webSiteScrollView.frame.height
            ? webSiteScrollView.frame.height
            : webSiteStackView.frame.height + offset

        if webSiteScrollView.contentSize.height != newContentHeight {
            webSiteScrollView.contentSize = CGSize(width: newContentWidth, height: newContentHeight)
        }
    }
    
    private func showBlockSelector() -> Bool {
        if blockSelectorScrollView.isHidden {
            blockSelectorScrollView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.blockSelectorScrollView.alpha = 1
            }, completion: nil)
            return true
        } else {
            return false
        }
    }
    
    private func hideBlockSelector() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.blockSelectorScrollView.alpha = 0
        }, completion: { _ in self.blockSelectorScrollView.isHidden = true })
    
    }
    
    private func moveBlock(up: Bool) {
        if webSiteStackView.subviews.count < 2 { return }
        if lastTapedBlockIndex == -1 { lastTapedBlockIndex = webSiteStackView.subviews.count - 1 }
        
        let oldIndex = lastTapedBlockIndex
        var newIndex: Int
        
        if up == true {
            if lastTapedBlockIndex == 0 { return }
            newIndex = lastTapedBlockIndex - 1
        } else {
            if lastTapedBlockIndex == webSiteStackView.subviews.count - 1 { return }
            newIndex = lastTapedBlockIndex + 1
        }
        
        let oldIndexY = webSiteStackView.subviews[oldIndex].center.y
        let newIndexY = webSiteStackView.subviews[newIndex].center.y

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.webSiteStackView.subviews[oldIndex].center.y = newIndexY
            self.webSiteStackView.subviews[newIndex].center.y = oldIndexY
        }, completion: { _ in
            self.webSiteStackView.exchangeSubview(at: oldIndex, withSubviewAt: newIndex)
            
            // Пришлось скопировать массив стеквью, обнулить исходный
            // и пересборать его по одному элементу, чтобы получить новый порядок
            
            let tempStackView = UIStackView()
            for subbiew in self.webSiteStackView.subviews {
                tempStackView.addArrangedSubview(subbiew)
                self.webSiteStackView.removeArrangedSubview(subbiew)
            }
            
            for subbview in tempStackView.subviews {
                self.webSiteStackView.addArrangedSubview(subbview)
            }
            
            self.lastTapedBlockIndex = newIndex
        })
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
                #warning ("Прочие типы дописать")
                addDivider(height: websiteBlock.value ?? 0)
            }
        }
        scrollViewHeightUpdate()
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
                #warning ("Прочие типы дописать")
            }
        }
        
        websitePage.websiteBlocks = websiteBlocks
    }
}


// MARK: - Main Buttobs IBActions
extension WebSiteBuilderViewController {

    @IBAction func addBlockButtonClicked() {
        if !showBlockSelector() { hideBlockSelector() }
    }
    
    @IBAction func addBlockChoicedAndClicked(sender: UIButton) {
        switch sender.tag {
        case 1: addTextBlock(with: .title, and: DefaultTextFor.title.rawValue)
        case 2: addTextBlock(with: .subtitle, and: DefaultTextFor.subtitle.rawValue)
        case 3: addTextBlock(with: .text, and: DefaultTextFor.text.rawValue)
        default: print("Еще нет кода для этого элемента")
        }
        
        hideBlockSelector()
        webSiteStackView.layoutIfNeeded()
        scrollViewHeightUpdate()
        
        
        let bottomOffset = CGPoint(
            x: 0,
            y: webSiteScrollView.contentSize.height -
               webSiteScrollView.bounds.height +
               webSiteScrollView.contentInset.bottom)
        
        webSiteScrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    @IBAction func moveBlockButtonClicked(sender: UIButton) {
        hideBlockSelector()
        
        if(sender.tag == 1) {
            moveBlock(up: false)
            // вниз
            // получить текущий активный элемент
            // если элемента нет, двигаем последний блок?
        } else {
            // вверх
            moveBlock(up: true)
        }
    }
}
