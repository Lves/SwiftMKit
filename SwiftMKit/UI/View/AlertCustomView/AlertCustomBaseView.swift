//
//  AlertCustomBaseView.swift
//  SwiftMKitDemo
//
//  Created by why on 16/5/26.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

public class AlertCustomBaseView: UIView {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblMainTitle : UILabel!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var lblViceTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblbottomTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lsToMainTitleSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var lsToImageViewSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var lsToViceTitleSpaceConstraint: NSLayoutConstraint!
    
    weak var currentViewController: UIViewController?
    
    
    @IBAction func click_CloseButton(sender: UIButton) {
        
        UIView.animateWithDuration(0.25, animations: {
            self.alpha = 0
        }) { completed in
            self.removeFromSuperview()
        }
        
    }
    
    @IBAction func click_NextButton(sender: UIButton) {
        
    }
    
    private struct InnerConst {
        static let NibName = "AlertCustomBaseView"
    }
    //Controller
    //CGSize size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //[self.headerView setHeight:size.height];
    
    public static func alertCustomView(currentViewController: UIViewController! , withMainTitle mainTitle: String? , withImage img: UIImage? , withViceTitle viceTitle: String? , withContent content: String? , withNextBtnName btnName: String? , withNextBtnRouteTo path:String! , withBottomTitle bottomTitle: String!) -> AlertCustomBaseView? {
        let view = NSBundle.mainBundle().loadNibNamed(InnerConst.NibName, owner: self, options: nil).first as? AlertCustomBaseView
        view?.currentViewController = currentViewController
        view?.frame = UIScreen.mainScreen().bounds
        view?.lblMainTitle.text = mainTitle
        view?.imageView.image = img
        view?.lblViceTitle.text = viceTitle
        view?.lblContent.text = content
        view?.btnNext.setTitle(btnName, forState: UIControlState.Normal)
        view?.lblbottomTitle.text = bottomTitle

        return view
    }
    
    public func showAlertCustomView() {
        var view = currentViewController!.view
        if let nav = currentViewController?.navigationController {
            view = nav.view
        }
        view.addSubview(self)
        
        self.alpha = 0
        UIView.animateWithDuration(0.25) {
            self.alpha = 1
        }

    }
    
}
