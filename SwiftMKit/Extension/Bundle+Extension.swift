//
//  Bundle+Extension.swift
//  SwiftMKit
//
//  Created by lixingle on 2018/8/16.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation


class MKBundleClass: NSObject {
}

extension Bundle{
    static func sourceBundle(bundleInClass:AnyClass, resource:String, type:String) -> Bundle?{
        if let path = Bundle(for: bundleInClass).path(forResource: resource, ofType: type){
            return Bundle(path: path)
        }
        return nil
    }
    static func smkitSourceBundle() -> Bundle?{
        return Bundle.sourceBundle(bundleInClass: BaseKitEmptyView.self, resource: "SMKit", type: "bundle")
    }
    static func imageInSource(bundle:Bundle, imageName:String) -> UIImage? {
        if let imagePath = bundle.path(forResource: imageName, ofType: nil){
            return UIImage(contentsOfFile: imagePath)
        }
        return nil
    }
    static func smkitPngImage(imageName:String) -> UIImage?{
        if let path = Bundle.smkitSourceBundle()?.path(forResource: imageName, ofType: "png"){
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}
