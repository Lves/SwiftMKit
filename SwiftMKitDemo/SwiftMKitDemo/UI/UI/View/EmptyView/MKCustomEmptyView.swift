//
//  MKCustomEmptyView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKCustomEmptyView: UIView {
    
    private struct InnerConst {
        static let NibName = "MKCustomEmptyView"
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    class func getView() -> MKCustomEmptyView {
        return NSBundle.mainBundle().loadNibNamed(InnerConst.NibName, owner: nil, options: nil).first as! MKCustomEmptyView
    }

}
