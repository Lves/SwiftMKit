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
    
    fileprivate var containerVc: GalaryCollectionViewController? {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(arc4random_uniform(30)) + 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: InnerConst.CellIdentifier)
        }
        cell!.textLabel?.text = "信用卡账单 ---- \(index)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lblHeaderView = UILabel()
        lblHeaderView.backgroundColor = UIColor.lightGray
        lblHeaderView.font = UIFont.systemFont(ofSize: 11)
        lblHeaderView.text = " 人民币账单"
        return lblHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    // MARK: - <GalaryCollectionViewDelegate>
    func galaryCollectionView(_ galaryCollectionView: UICollectionView, willSelectItemAtIndexPath indexPath: IndexPath, withUserInfo userInfo: [String : AnyObject]?) {
        print("即将选中  \(String(describing: userInfo))")
    }
    
    func galaryCollectionView(_ galaryCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath, withUserInfo userInfo: [String : AnyObject]?) {
        print("选中  \(String(describing: userInfo))")
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
    func galaryCollectionView(_ galaryCollectionView: UICollectionView, willSelectItemAtIndexPath indexPath: IndexPath, withUserInfo userInfo: [String: AnyObject]?)
    func galaryCollectionView(_ galaryCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath, withUserInfo userInfo: [String: AnyObject]?)
}

public extension GalaryCollectionViewDelegate {
    func galaryCollectionView(_ galaryCollectionView: UICollectionView, willSelectItemAtIndexPath indexPath: IndexPath, withUserInfo userInfo: [String: AnyObject]?) { }
    func galaryCollectionView(_ galaryCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath, withUserInfo userInfo: [String: AnyObject]?) { }
}

open class GalaryCollectionViewController: UICollectionViewController {
    lazy var lblDesc = UILabel()
    fileprivate var destCell: GalaryCollectionViewCell? {
        didSet {
            lblDesc.text = destCell?.lblDay.text
            var f = lblDesc.frame
            f.origin.y = destCell!.frame.origin.y * 0.5 - f.size.height * 0.5
            lblDesc.frame = f
        }
    }
    @IBOutlet weak var layout: GalaryLinearLayout!
    open weak var delegate: GalaryCollectionViewDelegate?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        lblDesc.frame = CGRect(x: 0, y: 2, width: UIScreen.main.bounds.size.width, height: 30)
        lblDesc.textAlignment = .center
        lblDesc.textColor = UIColor.white
        lblDesc.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(lblDesc)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 设置布局属性
        let width = collectionView!.frame.size.width * 0.69
        let height = collectionView!.frame.size.height * 0.71
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let cells = collectionView!.visibleCells
        destCell = cells.last as? GalaryCollectionViewCell
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
    }
    
    // MARK: <UICollectionViewDelegate>
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalaryCollectionCell", for: indexPath) as! GalaryCollectionViewCell
        
        cell.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256)) / 255.0, green: CGFloat(arc4random_uniform(256)) / 255.0, blue: CGFloat(arc4random_uniform(256)) / 255.0, alpha: 1.0);
        cell.tag = indexPath.row
        cell.lblDay.text = " 还款日：\(indexPath.row) / \(collectionView.numberOfItems(inSection: indexPath.section)) "
        return cell
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // collectionView自动滚动到某个cell
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.galaryCollectionView(collectionView, willSelectItemAtIndexPath: indexPath, withUserInfo: nil)
        // FIXME: 加个延迟，目的是让collectionView动画结束之后  再赋值！
        let delayInSeconds = 0.3
        let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            self.destCell = collectionView.cellForItem(at: indexPath) as? GalaryCollectionViewCell
            let params = ["model" : self.destCell!.tag]
            self.delegate?.galaryCollectionView(collectionView, didSelectItemAtIndexPath: indexPath, withUserInfo: params as [String : AnyObject]?)
        }
    }
    
    override open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = collectionView!.visibleCells
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
        let indexPath = IndexPath(item: destCell!.tag, section: 0)
        collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        let params = ["model" : destCell!.tag]
        self.delegate?.galaryCollectionView(collectionView!, didSelectItemAtIndexPath: indexPath, withUserInfo: params as [String : AnyObject]?)
    }
}

class GalaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblDay: UILabel!
}
