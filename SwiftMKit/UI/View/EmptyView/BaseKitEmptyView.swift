//
//  BaseKitEmptyView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

public class BaseKitEmptyView: UIView {
    
    private struct InnerConst {
        static let NibName = "BaseKitEmptyView"
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    public class func getView() -> BaseKitEmptyView {
        return NSBundle.mainBundle().loadNibNamed(InnerConst.NibName, owner: nil, options: nil).first as! BaseKitEmptyView
    }
}