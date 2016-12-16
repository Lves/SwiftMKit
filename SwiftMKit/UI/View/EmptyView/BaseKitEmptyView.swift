//
//  BaseKitEmptyView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

open class BaseKitEmptyView: UIView {
    
    fileprivate struct InnerConst {
        static let NibName = "BaseKitEmptyView"
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    open class func getView() -> BaseKitEmptyView {
        return Bundle.main.loadNibNamed(InnerConst.NibName, owner: nil, options: nil)!.first as! BaseKitEmptyView
    }
}
