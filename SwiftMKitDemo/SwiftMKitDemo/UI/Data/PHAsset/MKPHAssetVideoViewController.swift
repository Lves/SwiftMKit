//
//  MKPHAssetVideoViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 14/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Photos

class MKPHAssetVideoViewController: BaseListViewController {
    
    struct InnerConst {
        static let CellIdentifier = "MKPHAssetVideoTableViewCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    var assetsFetchResults: PHFetchResult<AnyObject>?
    
    var dataArray: [PHAsset] = []
    
    lazy fileprivate var _viewModel = BaseListViewModel()
    override var viewModel: BaseListViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    override var listViewType: ListViewType {
        get { return .none }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bvc = segue.destination as? MKPHAssetVideoDetailViewController,
            let cell = sender as? UITableViewCell {
            let index = tableView.indexPath(for: cell)
            bvc.asset = dataArray[index?.row ?? 0]
            bvc.dataArray = dataArray
        }
    }
    
    override func setupUI() {
        super.setupUI()
        self.tableView.tableFooterView = UIView()
        //Add a video in Simulator
//        if let a = NSBundle.mainBundle().pathForResource("test", ofType: "mov", inDirectory: nil) {
//            UISaveVideoAtPathToSavedPhotosAlbum(a, self, nil, nil)
//        }
        loadData()
    }
    override func loadData() {
        super.loadData()
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        assetsFetchResults = PHAsset.fetchAssets(with: .video, options: allPhotosOptions)
        for index in 0..<assetsFetchResults!.count {
            let asset = assetsFetchResults![index] as! PHAsset
            dataArray.append(asset)
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier, for: indexPath)
        let asset = dataArray[indexPath.row]
        cell.textLabel?.text = asset.value(forKey: "filename") as? String
        cell.detailTextLabel?.text = asset.duration.formatToTimeMMss()
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}


class MKPHAssetVideoDetailViewController: BaseViewController {
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblProgress: UISlider!
    @IBOutlet weak var toolbarTop: UIView!
    @IBOutlet weak var toolbarBottom: UIView!
    var asset: PHAsset?
//        {
//        didSet {
//            if let asset = asset {
//                do {
//                    if asset.mediaType == .Video {
//                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//                        try AVAudioSession.sharedInstance().setActive(false)
//                    } else {
//                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//                        try AVAudioSession.sharedInstance().setActive(true)
//                        
//                    }
//                } catch {
//                    print("Failed to set audio session category.  Error: \(error)")
//                }
//            }
//        }
//    }
    var dataArray: [PHAsset] = []
    
    lazy var player: VideoPlayer = { return VideoPlayer(viewController: self) }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    override func setupUI() {
        super.setupUI()
        UIViewController.attemptRotationToDeviceOrientation()
        if let oldValue =  UIDevice.current.value(forKey: "orientation") as? Int {
            let orientation = UIInterfaceOrientation(rawValue: oldValue)
            if orientation != .landscapeLeft && orientation != .landscapeRight {
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        }
        
        lblStartTime.font = UIFont(name: "DBLCDTempBlack", size: 18)
        lblEndTime.font = UIFont(name: "DBLCDTempBlack", size: 18)
        lblName.text = asset?.value(forKey: "filename") as? String
        
        player.btnPlay = btnPlay
        player.lblStartTime = lblStartTime
        player.lblEndTime = lblEndTime
        player.progressSlider = lblProgress
        player.toolbarTop = toolbarTop
        player.toolbarBottom = toolbarBottom
        player.endTime = asset?.duration ?? 0
        
        playAsset(asset!)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    func playAsset(_ asset: PHAsset) {
        self.asset = asset
        Async.background {
            PHImageManager.default().requestAVAsset(forVideo: self.asset!, options: nil) { (avasset, _, _) in
                Async.main {
                    if let urlAsset = avasset as? AVURLAsset {
                        self.player.readToPlay(urlAsset.url)
                    }
                }
            }
        }
    }
   
    
    @IBAction func click_close(_ sender: UIButton) {
        self.routeBack()
    }
    @IBAction func click_last(_ sender: UIButton) {
        var index = dataArray.indexesOf(asset!).first!
        index = max(index - 1, 0)
        let video = dataArray[index]
        playAsset(video)
    }
    @IBAction func click_back(_ sender: UIButton) {
        player.seekAddTime(-20)
        player.delayToolBarHidden()
    }
    @IBAction func click_fast(_ sender: UIButton) {
        player.seekAddTime(20)
        player.delayToolBarHidden()
    }
    @IBAction func click_next(_ sender: UIButton) {
        var index = dataArray.indexesOf(asset!).first!
        index = min(index + 1, dataArray.count - 1)
        let video = dataArray[index]
        playAsset(video)
    }
    
}

