//
//  CrashLogDetailViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//

import UIKit

class CrashLogDetailViewController: BaseKitViewController {

    @IBOutlet weak var textView: UITextView!
    
    var text: String?
   
    override func setupUI() {
        super.setupUI()
        textView.text = text
    }
}
