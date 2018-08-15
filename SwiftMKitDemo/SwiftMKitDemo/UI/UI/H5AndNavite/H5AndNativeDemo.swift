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
    var paramBool:Bool = false
    override func setupUI() {
        super.setupUI()
        print(" \n 参数 paramStr: \(String(describing: paramStr)) paramInt: \(paramInt) paramBool: \(paramBool)")
        
//        if let instanceClass:NSObject.Type = NSObject.fullClassName("H5DemoService") {
//        
//            instanceClass.setValue("5", forKey: "age")
//            instanceClass.setValue("1", forKey: "longy")
//            
//        }
  
    }

    @IBAction func toNextVC(_ sender: Any) {
//        self.route(toUrl: "MKIndicatorButtonViewController", params: ["title":"热修复" as AnyObject], pop: ["MKIndicatorButtonViewController":"https://www.baidu.com"])
    }
    
    @IBAction func toLocalH5(_ sender: Any) {
//        route(name: "LocalWebViewController")
        route(toUrl: "https://www.baidu.com")
    }
}

class H5DemoService: BaseService{
    static let sharedH5DemoService = H5DemoService()
    var applyId:Int = 0
    static var hello:String = "sss"
    static let world:String = "sss"
    static var age:Int = 0
    static var longly:Bool = false
}


