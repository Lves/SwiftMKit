//
//  MKUIGalaryCollectionViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/20/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKGalaryCollectionViewController: BaseViewController, GalaryCollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    struct InnerConst {
        static let CellIdentifier = "MKGalaryCollectionViewCell"
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    var index: Int = 0
    var lastIndex: Int = -1
    
    private var containerVc: GalaryCollectionViewController? {
        get {
            return (self.childViewControllers.first) as? GalaryCollectionViewController
        }
    }
    
    override func setupUI() {
        super.setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        
        containerVc?.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(arc4random_uniform(30)) + 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        cell!.textLabel?.text = "信用卡账单 ---- \(index)"
        return cell!
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lblHeaderView = UILabel()
        lblHeaderView.backgroundColor = UIColor.lightGrayColor()
        lblHeaderView.font = UIFont.systemFontOfSize(11)
        lblHeaderView.text = " 人民币账单"
        return lblHeaderView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    // MARK: - <GalaryCollectionViewDelegate>
    func galaryCollectionView(galaryCollectionView: UICollectionView, willSelectItemAtIndexPath indexPath: NSIndexPath, withUserInfo userInfo: [String : AnyObject]?) {
        print("即将选中  \(userInfo)")
    }
    
    func galaryCollectionView(galaryCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath, withUserInfo userInfo: [String : AnyObject]?) {
        print("选中  \(userInfo)")
        if let params = userInfo {
            index = Int(params["model"] as! NSNumber)
            if index != lastIndex {
                tableView.reloadData()
                lastIndex = index
            }
        }
    }
}

public protocol GalaryCollectionViewDelegate: class {
    func galaryCollectionView(galaryCollectionView: UICollectionView, willSelectItemAtIndexPath indexPath: NSIndexPath, withUserInfo userInfo: [String: AnyObject]?)
    func galaryCollectionView(galaryCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath, withUserInfo userInfo: [String: AnyObject]?)
}

public extension GalaryCollectionViewDelegate {
    func galaryCollectionView(galaryCollectionView: UICollectionView, willSelectItemAtIndexPath indexPath: NSIndexPath, withUserInfo userInfo: [String: AnyObject]?) { }
    func galaryCollectionView(galaryCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath, withUserInfo userInfo: [String: AnyObject]?) { }
}

public class GalaryCollectionViewController: UICollectionViewController {
    lazy var lblDesc = UILabel()
    private var destCell: GalaryCollectionViewCell? {
        didSet {
            lblDesc.text = destCell?.lblDay.text
            var f = lblDesc.frame
            f.origin.y = destCell!.frame.origin.y * 0.5 - f.size.height * 0.5
            lblDesc.frame = f
        }
    }
    @IBOutlet weak var layout: GalaryLinearLayout!
    public weak var delegate: GalaryCollectionViewDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        lblDesc.frame = CGRectMake(0, 2, UIScreen.mainScreen().bounds.size.width, 30)
        lblDesc.textAlignment = .Center
        lblDesc.textColor = UIColor.whiteColor()
        lblDesc.font = UIFont.systemFontOfSize(13)
        view.addSubview(lblDesc)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 设置布局属性
        let width = collectionView!.frame.size.width * 0.69
        let height = collectionView!.frame.size.height * 0.71
        layout.itemSize = CGSizeMake(width, height)
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 10
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let cells = collectionView!.visibleCells()
        destCell = cells.last as? GalaryCollectionViewCell
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
    
    // MARK: <UICollectionViewDelegate>
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GalaryCollectionCell", forIndexPath: indexPath) as! GalaryCollectionViewCell
        
        cell.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256)) / 255.0, green: CGFloat(arc4random_uniform(256)) / 255.0, blue: CGFloat(arc4random_uniform(256)) / 255.0, alpha: 1.0);
        cell.tag = indexPath.row
        cell.lblDay.text = " 还款日：\(indexPath.row) / \(collectionView.numberOfItemsInSection(indexPath.section)) "
        return cell
    }
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // collectionView自动滚动到某个cell
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        delegate?.galaryCollectionView(collectionView, willSelectItemAtIndexPath: indexPath, withUserInfo: nil)
        // FIXME: 加个延迟，目的是让collectionView动画结束之后  再赋值！
        let delayInSeconds = 0.3
        let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                    Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            self.destCell = collectionView.cellForItemAtIndexPath(indexPath) as? GalaryCollectionViewCell
            let params = ["model" : self.destCell!.tag]
            self.delegate?.galaryCollectionView(collectionView, didSelectItemAtIndexPath: indexPath, withUserInfo: params)
        }
    }
    
    override public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let cells = collectionView!.visibleCells()
        // 计算x方向的偏移量
        let offsetX = collectionView!.contentOffset.x;
        let middleW = collectionView!.frame.size.width * 0.5;
        destCell = cells.first as? GalaryCollectionViewCell
        var delta = abs(destCell!.frame.origin.x + destCell!.frame.size.width * 0.5 - (offsetX + middleW))
        for cell in cells {
            let currentDelta = abs(cell.frame.origin.x + cell.frame.size.width * 0.5 - (offsetX + middleW))
            if delta > currentDelta {
                delta = currentDelta
                destCell = cell as? GalaryCollectionViewCell
            }
        }
        // FIXME: 解决第一个cell 慢滑动时无法复位的bug!
        let indexPath = NSIndexPath(forItem: destCell!.tag, inSection: 0)
        collectionView!.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        let params = ["model" : destCell!.tag]
        self.delegate?.galaryCollectionView(collectionView!, didSelectItemAtIndexPath: indexPath, withUserInfo: params)
    }
}

class GalaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblDay: UILabel!
}