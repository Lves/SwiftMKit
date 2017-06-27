//
//  H5AndNativeDemo.swift
//  SwiftMKitDemo
//
//  Created by lixingle on 2017/6/26.
//  Copyright © 2017年 cdts. All rights reserved.
//

import UIKit

class H5AndNativeDemo: BaseViewController {
    var paramStr:String?
    var paramInt:Int = 0
    override func setupUI() {
        super.setupUI()
//        let alert = UIAlertController(title: "传递参数", message: , preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//        self.presentVC(alert)
        print(" \n 参数 paramStr: \(String(describing: paramStr)) paramInt: \(paramInt)")
    }

    @IBAction func toNextVC(_ sender: Any) {
        self.route(name: "MKIndicatorButtonViewController", h5Config: ["MKIndicatorButtonViewController":"https://www.baidu.com"], params: ["title":"热修复"])
    }
    
    @IBAction func toLocalH5(_ sender: Any) {
        route(name: "LocalWebViewController")
    }
}
