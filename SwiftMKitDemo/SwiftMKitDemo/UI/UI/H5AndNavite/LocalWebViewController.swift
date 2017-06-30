//
//  LocalWebViewController.swift
//  SwiftMKitDemo
//
//  Created by lixingle on 2017/6/26.
//  Copyright © 2017年 cdts. All rights reserved.
//

import UIKit

class LocalWebViewController: BaseWebViewController {

    override func setupUI() {
        super.setupUI()
        
        
    }
    override func loadData() {
        let path = Bundle.main.path(forResource: "toNativeDemo", ofType: ".html")
        let url = URL(fileURLWithPath: path!)
        self.webView.load( URLRequest(url: url))
    }
   

}
