//
//  MKUIOrderTableViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 13/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKOrderTableViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private struct InnerConst {
        static let CellID = "MKOrderTableViewCell"
    }
    
    var data: [MKOrderViewModel]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func setupUI() {
        super.setupUI()
        tableView.setEditing(true, animated: false)
        tableView.allowsSelectionDuringEditing = true
        loadData()
    }
    
    override func loadData() {
        super.loadData()
        data = []
        for index in 0..<10 {
            let model = MKOrderViewModel()
            model.name = "Cell" + index.toString
            model.code = String(index + 1000)
            model.value = 10000.toString
            data?.append(model)
        }
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellID) as? MKOrderTableViewCell else { return UITableViewCell() }
        cell.model = self.data?[indexPath.row] ?? MKOrderViewModel()
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.whiteColor() : UIColor(hex6: 0xF8F8F8)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = self.data?[indexPath.row] ?? MKOrderViewModel()
        model.isSelect = !model.isSelect
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    
    //在编辑状态，可以拖动设置cell位置
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //移动cell事件
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath != destinationIndexPath {
            //获取移动行对应的值
            if let model = data?[sourceIndexPath.row] {
                //删除移动的值
                data?.removeAtIndex(sourceIndexPath.row)
                //如果移动区域大于现有行数，直接在最后添加移动的值
                if sourceIndexPath.row > data?.count {
                    data?.append(model)
                } else {
                    //没有超过最大行数，则在目标位置添加刚才删除的值
                    data?.insert(model, atIndex: destinationIndexPath.row)
                }
            }
            tableView.reloadData()
        }
    }
    
    //删除、全选
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
}
