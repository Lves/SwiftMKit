//
//  CLLoopViewController.swift
//  SwiftMKitDemo
//
//  Created by HeLi on 17/1/10.
//  Copyright © 2017年 cdts. All rights reserved.
//

import UIKit
import SwiftMKit

class CLLoopViewController: UIViewController,CLLoopViewDelegate {
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let image1 = UIImage(named: "Barcelona0")!
        let image2 = UIImage(named: "Barcelona1")!
        let image3 = UIImage(named: "Barcelona2")!
        let image4 = UIImage(named: "Barcelona3")!
        _ = [image1,image2,image3,image4]
        
        let imageUrl1 = "http://www3.autoimg.cn/newsdfs/g23/M0E/A6/72/620x0_1_autohomecar__wKgFXFhPnaOAZ55GAAIzV2iouyc338.jpg"
        let imageUrl2 = "http://img00.hc360.com/pf/201103/201103111027473156.jpg"
        let imageUrl3 = "http://imgsrc.baidu.com/forum/mpic/item/8b82b2b78d2447d731add1ce.jpg"
        let imageUrl4 = "http://www.taopic.com/uploads/allimg/121209/267868-12120920015640.jpg"
        
        let imageUrls = [imageUrl1,imageUrl2,imageUrl3,imageUrl4]
        
        let rect = CGRect(x: 0, y: 22, w: self.view.frame.size.width, h: self.view.frame.size.width/16 * 9)
        let loopView = CLLoopView(frame: rect)
        self.view.addSubview(loopView)
        //add images
//        loopView.arrImage = images
        loopView.arrImageUrl = imageUrls
        
        //auto turn to next page
        loopView.autoShow = false
        loopView.showPageControl = false
        loopView.delegate = self
    }
    
    //MARK: - CLLoopView Delegate
    func selectLoopViewPage(idx: Int) {
        print("select page:\(idx)")
    }
}
