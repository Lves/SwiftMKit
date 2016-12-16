//
//  MKUIOrderTableViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 13/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MKOrderTableViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate struct InnerConst {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellID) as? MKOrderTableViewCell else { return UITableViewCell() }
        cell.model = self.data?[indexPath.row] ?? MKOrderViewModel()
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.white : UIColor(hex6: 0xF8F8F8)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.data?[indexPath.row] ?? MKOrderViewModel()
        model.isSelect = !model.isSelect
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
    
    
    //在编辑状态，可以拖动设置cell位置
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //移动cell事件
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath != destinationIndexPath {
            //获取移动行对应的值
            if let model = data?[sourceIndexPath.row] {
                //删除移动的值
                data?.remove(at: sourceIndexPath.row)
                //如果移动区域大于现有行数，直接在最后添加移动的值
                if sourceIndexPath.row > data?.count {
                    data?.append(model)
                } else {
                    //没有超过最大行数，则在目标位置添加刚才删除的值
                    data?.insert(model, at: destinationIndexPath.row)
                }
            }
            tableView.reloadData()
        }
    }
    
    //删除、全选
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
}
