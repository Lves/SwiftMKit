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
        print(" \n 参数 paramStr: \(String(describing: paramStr)) paramInt: \(paramInt)")
    }

    @IBAction func toNextVC(_ sender: Any) {
        self.route(name: "MKIndicatorButtonViewController", h5Config: ["MKIndicatorButtonViewController":"https://www.baidu.com"], params: ["title":"热修复"])
    }
    
    @IBAction func toLocalH5(_ sender: Any) {
//        route(name: "LocalWebViewController")
        route(toUrl: "http://loan-mobile.qa-02.jimu.com/hybird")
//        route(toUrl: "http://fund-wechat.qa-01.hongdianfund.com/mixin/hybird?token=hd@20161108")
    }
}
