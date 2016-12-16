//
//  MKCustomEmptyView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKCustomEmptyView: BaseKitEmptyView {
    
    fileprivate struct InnerConst {
        static let NibName = "MKCustomEmptyView"
    }
    
    override class func getView() -> MKCustomEmptyView {
        return Bundle.main.loadNibNamed(InnerConst.NibName, owner: nil, options: nil)!.first as! MKCustomEmptyView
    }

}
