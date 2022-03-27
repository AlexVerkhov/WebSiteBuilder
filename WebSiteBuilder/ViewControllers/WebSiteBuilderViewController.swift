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
        
        // TODO: здесь внутри методов бесполезно вызывается обновление высоты скролл вью
        addTitle()
        addSubTitle()
        //addDivider(height: 200)
        addText()
        //addDivider()
        //addImage()
        //addForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // На этом этапе становится известен размер stackView c элементами,
        // которые были созданы во viewDidLoad()
        addDivider(height: 2000)
        //addText()
        scrollViewHeightUpdate()
    }
}

// MARK: - Adding elements
extension WebSiteBuilderViewController {
    
    private func addTitle(with text: String? = nil) {
        let titleBlock = UITextView()
        titleBlock.text = text ?? "Заголовок"
        titleBlock.isScrollEnabled = false
        titleBlock.font = FontStyle.title
        
        //textBlock.font = subtitleTextView.font
        //scrollViewUpdateHeight()
        //addBlockTypeView.isHidden = true
        
        webSiteStackView.insertArrangedSubview(titleBlock, at: webSiteStackView.subviews.count)
        scrollViewHeightUpdate()
    }
    
    private func addSubTitle(with text: String? = nil) {
        let subTitleBlock = UITextView()
        subTitleBlock.text = text ?? "Подзаголовок"
        subTitleBlock.isScrollEnabled = false
        subTitleBlock.font = FontStyle.subTitle
        
        //textBlock.font = subtitleTextView.font
        //scrollViewUpdateHeight()
        //addBlockTypeView.isHidden = true
        
        webSiteStackView.insertArrangedSubview(subTitleBlock, at: webSiteStackView.subviews.count)
        scrollViewHeightUpdate()
    }
    
    private func addText(with text: String? = nil) {
        let textBlock = UITextView()
        textBlock.text = text ?? "Здесь будет ваш текст. Просто отредактируйте блок, тапнув по нему"
        textBlock.isScrollEnabled = false
        textBlock.font = FontStyle.text
        
        //textBlock.font = subtitleTextView.font
        //scrollViewUpdateHeight()
        //addBlockTypeView.isHidden = true
        
        webSiteStackView.insertArrangedSubview(textBlock, at: webSiteStackView.subviews.count)
        scrollViewHeightUpdate()
    }
    
    private func addDivider(height: Int = 10) {
        // TODO: не работает, как минимум, при первичном заполнении стека
        let dividerView = UIView()
        dividerView.frame.size.height = CGFloat(height)
       
        let a = UILabel()
        a.text = "12"
        dividerView.addSubview(a)
        webSiteStackView.insertArrangedSubview(dividerView, at: webSiteStackView.subviews.count)
    }
}


// MARK: - Update UI
extension WebSiteBuilderViewController {
    
    private func scrollViewHeightUpdate() {
        // TODO: Здесь необходимо точнее выверить высоту стэка на разных этапах
        let contentWidth = webSiteScrollView.bounds.width - 40
        
        print(webSiteStackView.frame.height)
        print(webSiteScrollView.frame.height)
        
        let contentHeight = webSiteStackView.frame.height < webSiteScrollView.frame.height
            ? webSiteScrollView.frame.height
            : webSiteStackView.frame.height + 200

        webSiteScrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
}


// MARK: - Save and Load scheme
extension WebSiteBuilderViewController {
    
    private func loadPageFromScheme() {
        // страницу из схемы создать пошагово
        // вообще не ясно, на каком жизн цикле вьюхи это делать, так как большую часть из них
        // у элементов просто нет высоты и ширины
    }
    
    private func savePageToScheme() {
        // перебрать элементы и сохранить их в схемы
    }
}
