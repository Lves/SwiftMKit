//
//  MKPHAssetImageViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 14/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Photos
import SwiftMKit

class MKPHAssetImageViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var assetsFetchResults: PHFetchResult<PHAsset>?
    
    var dataArray: [PHAsset] = []
    
    
    override func setupUI() {
        super.setupUI()
        loadData()
    }
    
    override func loadData() {
        super.loadData()
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        assetsFetchResults = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        for index in 0..<assetsFetchResults!.count {
            let asset = assetsFetchResults![index] 
            dataArray.append(asset)
        }
        collectionView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bvc = segue.destination as? MKPHAssetImageDetailViewController,
            let cell = sender as? MKPHAssetImageCell {
            bvc.asset = cell.asset
        }
    }
}

extension MKPHAssetImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //返回多少个cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    //返回自定义的cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MKPHAssetImageCell", for: indexPath) as! MKPHAssetImageCell
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
                PHCachingImageManager.default().requestImage(for: self.asset!, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil) { (image, info) in
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
            PHCachingImageManager.default().requestImage(for: self.asset!, targetSize: self.view.bounds.size, contentMode: .aspectFit, options: nil) { (image, info) in
                Async.main {
                    self.imageView.image = image
                }
            }
        }
    }
}
