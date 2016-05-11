//
//  MKUISegmentViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/11/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKUISegmentViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setupUI() {
        if let vc1 = self.instanceViewControllerInStoryboardWithName("MKUISegmentAViewController") {
            view.addSubview(vc1.view)
        }
        if let vc2 = self.instanceViewControllerInStoryboardWithName("MKUISegmentBViewController") {
            view.addSubview(vc2.view)
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
