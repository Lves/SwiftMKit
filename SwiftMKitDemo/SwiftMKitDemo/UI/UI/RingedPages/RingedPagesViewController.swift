//
//  RingedPagesViewController.swift
//  SwiftMKitDemo
//
//  Created by HeLi on 17/1/10.
//  Copyright © 2017年 cdts. All rights reserved.
//

import UIKit
import Haneke

class RingedPagesViewController: UIViewController, RingedPagesDataSource, RingedPagesDelegate {
    
    lazy var pages: RingedPages = {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let pagesFrame = CGRect(x: 0, y: 100, width: screenWidth, height: screenWidth * 0.4)
        let pages = RingedPages(frame: pagesFrame)
        let height = pagesFrame.size.height - pages.pageControlMarginBottom - pages.pageControlMarginTop - pages.pageControlHeight
        pages.carousel.mainPageSize = CGSize(width: height * 0.8, height: height)
        pages.carousel.pageScale = 0.6
        pages.dataSource = self
        pages.delegate = self
        return pages
    }()
    
    lazy var dataSource: [String] = {
        var array = [String]()
        let s = "ABCDEFG"
        for i in 0..<s.characters.count {
            array.append(String(s[i]))
        }
        
        let imageUrl1 = "http://www3.autoimg.cn/newsdfs/g23/M0E/A6/72/620x0_1_autohomecar__wKgFXFhPnaOAZ55GAAIzV2iouyc338.jpg"
        let imageUrl2 = "http://img00.hc360.com/pf/201103/201103111027473156.jpg"
        let imageUrl3 = "http://imgsrc.baidu.com/forum/mpic/item/8b82b2b78d2447d731add1ce.jpg"
        let imageUrl4 = "http://www.taopic.com/uploads/allimg/121209/267868-12120920015640.jpg"
        
        let imageUrls = [imageUrl1,imageUrl2,imageUrl3,imageUrl4]
        
        return array
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pages)
        pages.reloadData()
    }
    func numberOfItems(in ringedPages: RingedPages) -> Int {
        return dataSource.count
    }
    func ringedPages(pages: RingedPages, viewForItemAt index: Int) -> UIView {
        
        //UILabel
        var label: UILabel?
        if let view = pages.dequeueReusablePage() {
            if view is UILabel {
                label = view as? UILabel
            }
        }
        if label == nil {
            label = UILabel()
            label?.font = UIFont.systemFontOfSize(50)
            label?.textAlignment = .Center
            label?.textColor = UIColor.whiteColor()
            label?.layer.backgroundColor = UIColor.blackColor().CGColor
            label?.layer.cornerRadius = 5
        }
        label?.text = dataSource[index]
 
        /*
        var imgv: UIImageView?
        if let view = pages.dequeueReusablePage() {
            if view is UIImageView {
                imgv = view as? UIImageView
            }
        }
        if imgv == nil {
            imgv = UIImageView()
            imgv?.layer.backgroundColor = UIColor.blackColor().CGColor
            imgv?.layer.cornerRadius = 5
        }
        
        if let fromUrl : String = dataSource[index] {
            imgv?.hnk_setImageFromURL(NSURL(string: fromUrl)!, placeholder:UIImage(named:"view_default_loading"), format: Format<UIImage>(name: "original")) { image in
                imgv?.image = image
            }
        }
         */
        
        return label!
    }
    
    func didSelectPage(in pages: RingedPages ,pageIndex: Int) {
        print("pages selected, the current index is \(pages.currentIndex) pageIndex is \(pageIndex)" )
    }
    func ringedPages(pages: RingedPages, didScrollTo index: Int) {
        print("Did scrolled to index: \(index)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func changeMainPageSize(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            pages.carousel.mainPageSize = CGSize(width: 60, height: 100)
        case 2:
            pages.carousel.mainPageSize = CGSize(width: 200, height: 100)
        default:
            pages.carousel.mainPageSize = originMainPageSize
        }
        pages.reloadData()
    }
    var originMainPageSize: CGSize {
        var height = UIScreen.mainScreen().bounds.size.width * 0.4
        height -= (pages.pageControlMarginBottom + pages.pageControlMarginTop + pages.pageControlHeight)
        return CGSize(width: height * 0.8, height: height)
    }
    @IBAction func changePageScale(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            pages.carousel.pageScale = 0.8
        case 2:
            pages.carousel.pageScale = 0.5
        default:
            pages.carousel.pageScale = 0.6
        }
        pages.reloadData()
    }
}

public extension String {
    public subscript(index: Int) -> Character {
        let index = self.startIndex.advancedBy(index)
        return self[index]
    }
}

