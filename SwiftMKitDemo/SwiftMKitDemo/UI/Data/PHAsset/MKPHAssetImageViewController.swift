//
//  MKPHAssetImageViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 14/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Photos

class MKPHAssetImageViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var assetsFetchResults: PHFetchResult?
    
    var dataArray: [PHAsset] = []
    
    
    override func setupUI() {
        super.setupUI()
        loadData()
    }
    
    override func loadData() {
        super.loadData()
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        assetsFetchResults = PHAsset.fetchAssetsWithMediaType(.Image, options: allPhotosOptions)
        for index in 0..<assetsFetchResults!.count {
            let asset = assetsFetchResults![index] as! PHAsset
            dataArray.append(asset)
        }
        collectionView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let bvc = segue.destinationViewController as? MKPHAssetImageDetailViewController,
            let cell = sender as? MKPHAssetImageCell {
            bvc.asset = cell.asset
        }
    }
}

extension MKPHAssetImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    //返回多少个cell
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    //返回自定义的cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MKPHAssetImageCell", forIndexPath: indexPath) as! MKPHAssetImageCell
        let model = dataArray[indexPath.row]
        cell.asset = model
        return cell
    }
    
}

class PHAssetImageModel: NSObject {
    
}


class MKPHAssetImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var asset: PHAsset? {
        didSet {
            Async.background {
                PHCachingImageManager.defaultManager().requestImageForAsset(self.asset!, targetSize: CGSize(width: 100, height: 100), contentMode: .AspectFit, options: nil) { (image, info) in
                    Async.main {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
}


class MKPHAssetImageDetailViewController: BaseViewController {
    @IBOutlet weak var imageView: UIImageView!
    var asset: PHAsset?
    
    override func setupUI() {
        super.setupUI()
        Async.background {
            PHCachingImageManager.defaultManager().requestImageForAsset(self.asset!, targetSize: self.view.bounds.size, contentMode: .AspectFit, options: nil) { (image, info) in
                Async.main {
                    self.imageView.image = image
                }
            }
        }
    }
}
