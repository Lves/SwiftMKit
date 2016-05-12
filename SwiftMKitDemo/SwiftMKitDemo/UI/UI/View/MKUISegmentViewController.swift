//
//  MKUISegmentViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/11/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKUISegmentViewController: BaseViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    var segmentContainer: SegmentContainerViewController {
        get { return childViewControllers.first as! SegmentContainerViewController }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setupUI() {
        super.setupUI()
        let vc1 = self.instanceViewControllerInStoryboardWithName("MKUISegmentAViewController")!
        let vc2 = self.instanceViewControllerInStoryboardWithName("MKUISegmentBViewController")!
        segmentContainer.addSegmentViewControllers([vc1,vc2])
    }
    override func bindingData() {
        super.bindingData()
        segment.rac_signalForControlEvents(.ValueChanged).toSignalProducer().startWithNext { [weak self] _ in
            let index = self?.segment.selectedSegmentIndex ?? 0
            DDLogInfo("Segment index: \(index)")
            self?.segmentContainer.selectSegment(index)
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
