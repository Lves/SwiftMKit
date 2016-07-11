//
//  MKUICoverFlowViewController.swift
//  SwiftMKitDemo
//
//  Created by why on 16/5/31.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

class MKUICoverFlowViewController: BaseViewController, UICollectionViewDelegate , UICollectionViewDataSource{

    @IBOutlet weak var _photosCollectionView: UICollectionView!
    @IBOutlet weak var _coverFlowLayout: CoverFlowLayout!

    var _originalItemSize: CGSize!
    var _originalCollectionViewSize: CGSize!

    
    override func setupUI() {
        super.setupUI()
        
        _originalItemSize = _coverFlowLayout.itemSize
        _originalCollectionViewSize = _photosCollectionView.bounds.size
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _coverFlowLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        _coverFlowLayout.itemSize = CGSizeMake(_photosCollectionView.bounds.size.width * _originalItemSize.width / _originalCollectionViewSize.width, _photosCollectionView.bounds.size.height * _originalItemSize.height / _originalCollectionViewSize.height)
        
        _photosCollectionView.setNeedsLayout()
        _photosCollectionView.layoutIfNeeded()
        _photosCollectionView.reloadData()
        
        
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CoverFlowCollectionCell", forIndexPath: indexPath)
        cell
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }

}
