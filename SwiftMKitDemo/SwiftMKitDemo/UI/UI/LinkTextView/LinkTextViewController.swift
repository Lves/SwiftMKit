//
//  LinkTextViewController.swift
//  SwiftMKitDemo
//
//  Created by lixingle on 2018/2/7.
//  Copyright © 2018年 cdts. All rights reserved.
//

import UIKit

class LinkTextViewController: BaseViewController,LinkTextViewDelegate {
    var navi:UINavigationController?
    lazy fileprivate var _viewModel = BaseKitViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override func setupUI() {
        super.setupUI()
        title = "超链接富文本"
        
        let linkView = LinkTextView(frame: CGRect(x: 0, y: 100, width: view.w, height: 100))
        linkView.backgroundColor = UIColor(hex6:0xefeff4)
        linkView.delegate = self
        linkView.content = "已阅读并同意《登录注册协议》、《用户协议》和用户须知。华发商都破坏公平是梵蒂冈胡搜发货代购是否ID家公司将东方国际搜地方呢就能搜到佛寺附近发动机盖我哦啊就是滴哦房价爱的世界佛爱爱"
        /// 可选类型设置
        linkView.lineSpacing = 10
        linkView.font = UIFont.systemFont(ofSize: 14)
        linkView.textColor = UIColor(hex6:0x666666)
        linkView.alignment = .left
        /// 可选类型设置 end
        let linkModel1 = LinkTextModel(range: NSRange(location: 6, length: 8), textColor: UIColor.blue, url: "https://www.baidu.com")
        let linkModel2 = LinkTextModel(range: NSRange(location: 15, length: 6), textColor: UIColor.blue, url: "https://www.jd.com",showUnderline:true)
        let linkModel3 = LinkTextModel(range: NSRange(location: 22, length: 4), textColor: UIColor.red, url: "https://www.idumiao.com", font: UIFont.systemFont(ofSize: 25),highlightedBgColor:UIColor.blue)
        //设置链接
        linkView.linkArray = [linkModel1, linkModel2, linkModel3]
        linkView.h = linkView.heigthForContent
        view.addSubview(linkView)
    }
    ///代理
    func linkTextView(textView: LinkTextView?, didSelected model: LinkTextModel?) {
        self.route(toUrl: model?.url ?? "")
    }
}
