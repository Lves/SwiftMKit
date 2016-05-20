//
//  MKUIGalaryCollectionViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/20/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKUIGalaryCollectionViewController: BaseListViewController {
    @IBOutlet weak var tableView: UITableView!

    override var listView: UIScrollView! {
        get { return tableView }
    }
    
    private var _viewModel = MKUIGalaryCollectionViewModel()
    override var viewModel: BaseKitViewModel!{
        get { return _viewModel }
    }
}

class GalaryCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var layout: GalaryLinearLayout!
}

class GalaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblDay: UILabel!
}