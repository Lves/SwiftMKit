//
//  MKUISegmentViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/11/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ReactiveCocoa

class MKSegmentViewController: BaseViewController, SegmentContainerViewControllerDelegate {

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
    
    func didSelectSegment(_ segmentContainer: SegmentContainerViewController, index: Int, viewController: UIViewController, percentX: CGFloat) {
        segment.selectedSegmentIndex = index
    }
    
    override func setupUI() {
        super.setupUI()
        let vc1 = self.instanceViewControllerInStoryboard(withName: "MKSegmentAViewController")!
        let vc2 = self.instanceViewControllerInStoryboard(withName: "MKSegmentBViewController")!
        segmentContainer.delegate = self
        segmentContainer.addSegmentViewControllers([vc1,vc2])
    }
    override func bindingData() {
        super.bindingData()
        segment.reactive.selectedSegmentIndexes.observeValues { [weak self] _ in
            let index = self?.segment.selectedSegmentIndex ?? 0
            DDLogInfo("Segment index: \(index)")
            let _ = self?.segmentContainer.selectSegment(index)
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
