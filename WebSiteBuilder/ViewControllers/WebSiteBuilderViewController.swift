//
//  ViewController.swift
//  WebSiteBuilder
//
//  Created by Алексей Верховых on 27.03.2022.
//

import UIKit

#warning("Когда длинная страница и MoveUp происходит на за пределами эркана, хорошо бы сначала туда перемещать экран")
#warning("Также вопрос, можно ли нормально вставить блок не в конец, а в середину stack view arranged subviews")
#warning("Дивайдер в виде вьюхи? и внутри элемент")

class WebSiteBuilderViewController: UIViewController {
    
    var websitePage: WebSitePage!
    var currentBlockIndex: Int = -1
    var animationInProgress: Bool = false
    
    @IBOutlet var pageScrollView: UIScrollView!
    @IBOutlet var pageStackView: UIStackView!
    
    @IBOutlet var newBlockSelectorScrollView: UIScrollView!
    @IBOutlet var newBlockSelectorStackView: UIStackView!
    
    @IBOutlet var blockSettingsView: UIView!
    @IBOutlet var blockSettingsStackView: UIStackView!
    
    @IBOutlet var pageMenuBarButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.overrideUserInterfaceStyle = .light
        
        newBlockSelectorScrollView.isHidden = true
        newBlockSelectorScrollView.alpha = 0
        
        blockSettingsView.isHidden = true
        blockSettingsView.alpha = 0
        blockSettingsView.backgroundColor = .white
        
        pageScrollView.backgroundColor = .white
        pageStackView.backgroundColor = .white
        
        if let _ = websitePage {
            if websitePage.websiteBlocks.isEmpty { websitePage.websiteBlocks = DataManager.getDemoPageBlocks() }
        } else {
            websitePage = DataManager.getDemoPage(isLong: true)
        }
        
        newBlockSelectorStackView.layoutIfNeeded()
        newBlockSelectorScrollView.contentSize = CGSize(width: newBlockSelectorStackView.frame.width, height: newBlockSelectorStackView.frame.height)
        
        loadPageFromScheme()
    }
}


// MARK: - Block Edit functions
extension WebSiteBuilderViewController {

    private func addTextBlock(with blockType: pageBlockType, and text: String) {
        let textBlock = UITextViewBlock()
        textBlock.blockType = blockType
        
        switch blockType {
        case .title: textBlock.font = FontStyle.title
        case .subtitle: textBlock.font = FontStyle.subTitle
        default: textBlock.font = FontStyle.text
        }
    
        textBlock.text = text
        textBlock.delegate = self
        
        textBlock.isScrollEnabled = false
        textBlock.isUserInteractionEnabled = true
        textBlock.autocorrectionType = .no
        textBlock.spellCheckingType = .no
        textBlock.smartInsertDeleteType = .no
        textBlock.returnKeyType = .continue
        
        pageStackView.addArrangedSubview(textBlock)
        currentBlockIndex = pageStackView.arrangedSubviews.count-1
    }
    
    
    @objc private func deleteCurrentBlock() {
        if pageStackView.arrangedSubviews.count == 0 ||
            (0..<pageStackView.arrangedSubviews.count).contains(currentBlockIndex) == false { return }
        
        if pageStackView.arrangedSubviews.count > (currentBlockIndex + 1) {
            let yOffset = pageStackView.arrangedSubviews[currentBlockIndex + 1].frame.origin.y - pageStackView.arrangedSubviews[currentBlockIndex].frame.origin.y
            
            UIStackView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                for blockIndex in self.currentBlockIndex ..< self.pageStackView.arrangedSubviews.count {
                    self.pageStackView.arrangedSubviews[blockIndex].frame.origin.y -= yOffset
                }
            }, completion: { _ in })
        }
        
        pageStackView.arrangedSubviews[currentBlockIndex].removeFromSuperview()
        
        if currentBlockIndex > pageStackView.arrangedSubviews.count - 1 {
            currentBlockIndex = pageStackView.arrangedSubviews.count - 1
        }
        
        pageScrollViewContentHeightUpdate()
        hideBlockSettingsMenu()
    }
    
    
    private func moveBlock(way: moveBlockWay) {
        if pageStackView.arrangedSubviews.count < 2 ||
            currentBlockIndex == -1 ||
            animationInProgress { return }

        let oldIndex = currentBlockIndex
        var newIndex: Int
        
        if way == .up {
            if currentBlockIndex == 0 { return }
            newIndex = currentBlockIndex - 1
        } else {
            if currentBlockIndex == pageStackView.arrangedSubviews.count - 1 { return }
            newIndex = currentBlockIndex + 1
        }
        
        let oldIndexY = pageStackView.arrangedSubviews[oldIndex].center.y
        let newIndexY = pageStackView.arrangedSubviews[newIndex].center.y

        animationInProgress = true
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.pageStackView.arrangedSubviews[oldIndex].center.y = newIndexY
            self.pageStackView.arrangedSubviews[newIndex].center.y = oldIndexY
        }, completion: { _ in
            self.animationInProgress = false
        })
        
        self.pageStackView.exchangeSubview(at: oldIndex, withSubviewAt: newIndex)
        
        let tempStackView = UIStackView()
        
        pageStackView.subviews.forEach { subview in
            tempStackView.addArrangedSubview(subview)
            pageStackView.removeArrangedSubview(subview)
        }
        
        tempStackView.subviews.forEach { subview in
            pageStackView.addArrangedSubview(subview)
            tempStackView.removeArrangedSubview(subview)
        }
        
        currentBlockIndex = newIndex
    }
    
    
    // TODO: Эти наработки для клика по картинке, к примеру,
    // TODO: чтобы выбрать ее блок как текущий и активировать редактирование
    
    // это в момент создания кнопки
    //let blockTap = UITapGestureRecognizer(target: self, action: #selector(setActiveBlock(_:)))
    //textBlock.addGestureRecognizer(blockTap)

//    @objc private func setActiveBlock(_ sender: UITapGestureRecognizer) {
//        for pageIndex in 0..<webSiteStackView.arrangedSubviews.count {
//            if webSiteStackView.arrangedSubviews[pageIndex] == sender.view {
//                currentBlock = pageIndex
//                let textBlock = webSiteStackView.arrangedSubviews[pageIndex]
//
//                switch textBlock {
//                case is UITextViewBlock:
//                    if let temp = textBlock as? UITextView {
//                        temp.selectedRange = NSMakeRange(temp.text.count, 0);
//                        temp.becomeFirstResponder()
//                    }
//                default:
//                    print("default")
//                }
//
//            }
//        }
//        hideBlockSelector()
//    }
}


// MARK: - Page Scroll View UI update
extension WebSiteBuilderViewController {
    
    private func pageScrollViewContentHeightUpdate() {
        pageStackView.layoutIfNeeded()
        
        let newContentWidth = pageScrollView.frame.width
        let newContentHeight = pageStackView.frame.height < pageScrollView.frame.height
            ? pageScrollView.frame.height
            : pageStackView.frame.height

        if pageScrollView.contentSize.height != newContentHeight {
            pageScrollView.contentSize = CGSize(width: newContentWidth, height: newContentHeight)
        }
    }
    

    private func pageScrollViewScrollDown() {
        let bottomOffset = CGPoint(
            x: 0,
            y: pageScrollView.contentSize.height -
               pageScrollView.bounds.height +
               pageScrollView.contentInset.bottom)
        
        pageScrollView.setContentOffset(bottomOffset, animated: true)
    }
}


// MARK: - Text Field Delegate
extension WebSiteBuilderViewController: UITextViewDelegate {
    
    private func addKeyboardToolbar(textBlock: UITextView) {
        let toolBar = UIToolbar()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain,
                                         target: self, action: #selector(keyboardToolbarDonePressed))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.sizeToFit()
        
        textBlock.delegate = self
        textBlock.inputAccessoryView = toolBar
    }
    
    
    @objc private func keyboardToolbarDonePressed() {
        view.endEditing(true)
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView is UITextViewBlock {
            pageScrollViewContentHeightUpdate()
        }
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        currentBlockIndex = pageStackView.arrangedSubviews.firstIndex(of: textView) ??
            pageStackView.arrangedSubviews.count - 1
        
        addKeyboardToolbar(textBlock: textView)
        updateEnabledStatusOfMenuButtons()
        
        hideNewBlockSelector()
        if !blockSettingsView.isHidden { hideBlockSettingsMenu() }
        return true
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.count == 0 {
            deleteCurrentBlock()
        }
        textView.inputAccessoryView = nil
        return true
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
                // TODO: прочие типы
                print("Прочие типы")
            }
        }
        currentBlockIndex = pageStackView.arrangedSubviews.count - 1
        pageScrollView.layoutIfNeeded()
        pageScrollViewContentHeightUpdate()
    }
    
    
    private func savePageToScheme() {
        var websiteBlocks: [WebSiteBlock] = []
        pageStackView.arrangedSubviews.forEach { webSiteBlock in
            switch webSiteBlock {
            case let textBlock as UITextViewBlock:
                websiteBlocks.append(
                    WebSiteBlock(with: textBlock.blockType,
                                 andText: textBlock.text)
                )
            default:
                // TODO: прочие типы
                print("Прочие типы")
            }
        }
        
        websitePage.websiteBlocks = websiteBlocks
    }
}


// MARK: - Menu buttons IBActions
extension WebSiteBuilderViewController {

    @IBAction func addBlockButtonClicked() {
        hideBlockSettingsMenu()
        hidePageSettings()
        
        if newBlockSelectorScrollView.isHidden == false {
            hideNewBlockSelector()
        } else {
            showNewBlockSelector()
        }
    }
    

    @IBAction func blockSettingsButtonClicked() {
        hideNewBlockSelector()
        hidePageSettings()
        
        if blockSettingsView.isHidden {
            showBlockSettingsMenu()
        } else {
            hideBlockSettingsMenu()
        }
    }
    

    @IBAction func createBlockButtonsClicked(sender: UIButton) {
        switch sender.tag {
        case 1: addTextBlock(with: .title, and: DefaultTextFor.title.rawValue)
        case 2: addTextBlock(with: .subtitle, and: DefaultTextFor.subtitle.rawValue)
        case 3: addTextBlock(with: .text, and: DefaultTextFor.text.rawValue)
        default: print("Еще нет логики для этого элемента")
        }
        
        hideNewBlockSelector()
        pageScrollViewContentHeightUpdate()
        
        pageScrollViewScrollDown()
    }
    

    @IBAction func moveBlockButtonClicked(sender: UIButton) {
        hideNewBlockSelector()
        hideBlockSettingsMenu()
        
        sender.tag == 2
            ? moveBlock(way: .down)
            : moveBlock(way: .up)
        
        updateEnabledStatusOfMenuButtons()
    }

    
    @IBAction func pageSettingsButtonClick() {
        hideNewBlockSelector()
        hideBlockSettingsMenu()
        
        // TODO: Show menu view with methods
        
        hidePageSettings()
        showPageSettings()
    }
    
}


// MARK: Menu UI update
extension WebSiteBuilderViewController {
    
    private func createBlockSettingsMenu(for blockIndex: Int) {
        guard (0..<pageStackView.arrangedSubviews.count).contains(blockIndex) else { return }
        
        blockSettingsStackView.arrangedSubviews.forEach { subview in subview.removeFromSuperview() }
        
        blockSettingsStackView.insertArrangedSubview(
            createBlockSettingsMenuButton(
                iconString: "trash",
                selector: #selector(deleteCurrentBlock)),
            at: 0
        )
        
        // TODO: В зависимости от типа блока, добавлять разные кнопки
        switch pageStackView.arrangedSubviews[blockIndex] {
        case is UITextViewBlock:
            // TODO: Цвет и размер
            print("Добавить остальные кнопки")
        default:
            // TODO: Количесто фото
            print("Добавить свойства остальных кнопок")
            // другие свойства других элементов
        }
    }
    
    
    private func createBlockSettingsMenuButton(iconString: String, selector: Selector) -> UIButton {
        let newButton = UIButton()
        
        let symbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 36,
            weight: .light,
            scale: .unspecified
        )
        
        let buttonImage = UIImage(systemName: iconString, withConfiguration: symbolConfiguration)
        newButton.setImage(buttonImage, for: .normal)
        newButton.addTarget(
            nil,
            action: selector,
            for: .touchUpInside
        )
        
        return newButton
    }
    

    private func showNewBlockSelector() {
        if newBlockSelectorScrollView.isHidden {
            newBlockSelectorScrollView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.newBlockSelectorScrollView.alpha = 1
            }, completion: nil)
        }
    }
    

    private func showBlockSettingsMenu() {
        if currentBlockIndex == -1 ||
            pageStackView.arrangedSubviews.count < (currentBlockIndex + 1) ||
            blockSettingsView.isHidden == false {
                updateEnabledStatusOfMenuButtons()
                return
        }
        
        createBlockSettingsMenu(for: currentBlockIndex)
        
        blockSettingsView.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            self.blockSettingsView.alpha = 1
        } completion: { _ in }
    }
    
    
    private func showPageSettings() {
        // TODO: сделать
    }
    
    
    private func hideBlockSettingsMenu() {
        if blockSettingsView.isHidden == false {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
                self.blockSettingsView.alpha = 0
            } completion: { _ in self.blockSettingsView.isHidden = true }
        }
    }
    

    private func hideNewBlockSelector() {
        if newBlockSelectorScrollView.isHidden == false {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.newBlockSelectorScrollView.alpha = 0
            }, completion: { _ in self.newBlockSelectorScrollView.isHidden = true })
        }
    }


    private func hidePageSettings() {
        // TODO: сделать
    }
    
    
    private func updateBlockSettingsButtonEnabledStatus() {
        if currentBlockIndex == -1 ||
            pageStackView.arrangedSubviews.count == 0 ||
            pageStackView.arrangedSubviews.count < (currentBlockIndex + 1) {
                pageMenuBarButtons[webPageMenuButtons.blockSettings.rawValue].isEnabled = false
        } else if pageMenuBarButtons[webPageMenuButtons.blockSettings.rawValue].isEnabled == false {
            pageMenuBarButtons[webPageMenuButtons.blockSettings.rawValue].isEnabled = true
        }
    }


    
    
    private func updatePlusButtonEnabledStatus() {
        if pageStackView.arrangedSubviews.count >= WebSiteConstants.maxBlocksPerPage &&
           pageMenuBarButtons[webPageMenuButtons.addBlock.rawValue].isEnabled == true {
                pageMenuBarButtons[webPageMenuButtons.addBlock.rawValue].isEnabled = false
        } else if pageStackView.arrangedSubviews.count < WebSiteConstants.maxBlocksPerPage &&
                  pageMenuBarButtons[webPageMenuButtons.addBlock.rawValue].isEnabled == false {
                        pageMenuBarButtons[webPageMenuButtons.addBlock.rawValue].isEnabled = true
        }
    }
    
    
    private func updateEnabledStatusOfMenuButtons() {
        updatePlusButtonEnabledStatus()
        updateMoveButtonsEnabledStatus()
        updateBlockSettingsButtonEnabledStatus()
    }
    
    
    private func updateMoveButtonsEnabledStatus() {
        if currentBlockIndex == -1 ||
            pageStackView.arrangedSubviews.count == 0 ||
            pageStackView.arrangedSubviews.count < (currentBlockIndex + 1) {
                pageMenuBarButtons[webPageMenuButtons.moveDown.rawValue].isEnabled = false
                pageMenuBarButtons[webPageMenuButtons.moveUp.rawValue].isEnabled = false
        } else if currentBlockIndex == 0 {
            if pageMenuBarButtons[webPageMenuButtons.moveUp.rawValue].isEnabled == true {
                pageMenuBarButtons[webPageMenuButtons.moveUp.rawValue].isEnabled = false
            }
        } else if currentBlockIndex == pageStackView.arrangedSubviews.count - 1 {
            if pageMenuBarButtons[webPageMenuButtons.moveDown.rawValue].isEnabled == true {
                pageMenuBarButtons[webPageMenuButtons.moveDown.rawValue].isEnabled = false
            }
        } else {
            if pageMenuBarButtons[webPageMenuButtons.moveDown.rawValue].isEnabled == false {
                pageMenuBarButtons[webPageMenuButtons.moveDown.rawValue].isEnabled = true
            }
            
            if pageMenuBarButtons[webPageMenuButtons.moveUp.rawValue].isEnabled == false {
                pageMenuBarButtons[webPageMenuButtons.moveUp.rawValue].isEnabled = true
            }
        }
    }
}
