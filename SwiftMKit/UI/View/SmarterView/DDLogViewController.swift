//
//  DDLogViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class DDLogViewController: BaseKitViewController {

    @IBOutlet weak var textView: UITextView!
    
    private var _viewModel = BaseKitViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
    override func awakeFromNib() {
        print("")
    }
    
    override func setupUI() {
        super.setupUI()
        title = "Logs"
        loadData()
    }
    
    override func loadData() {
        super.loadData()
        if let logger = DDLog.allLoggers.filter({ $0 is DDFileLogger }).first as? DDFileLogger {
            let path = logger.currentLogFileInfo.filePath ?? ""
            let content = try? String.init(contentsOfFile: path)
            textView.text = content
            textView.layoutIfNeeded()
            Async.main(after: 0.4, {
                self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.length - 1, 1))
                self.textView.selectedRange = NSMakeRange(self.textView.text.length - 1, 0)
            })
        }
    }
    

}
