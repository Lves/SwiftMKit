//
//  MKiPodVideoViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 14/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import MediaPlayer

class MKiPodAssetViewController: BaseListViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct InnerConst {
        static let CellIdentifier = "MKiPodAssetTableViewCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var source: [String: [MPMediaItem]] = [:]
    
    lazy private var _viewModel = BaseListViewModel()
    override var viewModel: BaseListViewModel!{
        get { return _viewModel }
    }
    override var listView: UIScrollView! {
        get { return tableView }
    }
    override var listViewType: ListViewType {
        get { return .None }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let bvc = segue.destinationViewController as? MKiPodVideoDetailViewController,
            let asset = sender as? MPMediaItem {
            bvc.asset = asset
            if segue.identifier == "routeToVideo" {
                bvc.dataArray = source["Movie"]!
            } else if segue.identifier == "routeToSong"{
                bvc.dataArray = source["Song"]!
            }
        }
    }
    
    override func setupUI() {
        super.setupUI()
        self.tableView.tableFooterView = UIView()
        loadData()
    }
    override func loadData() {
        super.loadData()
        let query = MPMediaQuery()
        let items = query.items ?? []
        
        source["Movie"] = []
        source["Song"] = []
        for item in items {
            let type = item.mediaType
            if type == .Movie {
                source["Movie"]?.append(item)
            } else {
                source["Song"]?.append(item)
            }
        }
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return source["Movie"]?.count ?? 0
        }
        return source["Song"]?.count ?? 0
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, w: self.view.w, h: 40))
        view.backgroundColor = UIColor.lightGrayColor()
        let label = UILabel(frame: view.bounds)
        label.text = (section == 0 ? "Movie" : "Song")
        label.font = UIFont.systemFontOfSize(16)
        label.textColor = UIColor.whiteColor()
        label.x = 10
        view.addSubview(label)
        return view
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(InnerConst.CellIdentifier, forIndexPath: indexPath)
        let section = (indexPath.section == 0 ? "Movie" : "Song")
        if let asset = source[section]?[indexPath.row] {
            cell.textLabel?.text = asset.title
            cell.detailTextLabel?.text = asset.playbackDuration.formatToTimeMMss()
        } else {
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            if let asset = source["Movie"]?[indexPath.row] {
                self.performSegueWithIdentifier("routeToVideo", sender: asset)
            }
        } else {
            if let asset = source["Song"]?[indexPath.row] {
                self.performSegueWithIdentifier("routeToSong", sender: asset)
            }
        }
    }
    
}

class MKiPodVideoDetailViewController: BaseViewController {
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblProgress: UISlider!
    @IBOutlet weak var toolbarTop: UIView!
    @IBOutlet weak var toolbarBottom: UIView!
    var asset: MPMediaItem?
//        {
//        didSet {
//            if let asset = asset {
//                do {
//                    if asset.mediaType == .Movie {
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
    var dataArray: [MPMediaItem] = []
    
    lazy var player: VideoPlayer = { return VideoPlayer(viewController: self) }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()) {
            UIDevice.currentDevice().setValue(Int(UIInterfaceOrientation.Portrait.rawValue), forKey: "orientation")
        }
    }
    
    override func setupUI() {
        super.setupUI()
        UIViewController.attemptRotationToDeviceOrientation()
        if let oldValue =  UIDevice.currentDevice().valueForKey("orientation") as? Int {
            let orientation = UIInterfaceOrientation(rawValue: oldValue)
            if orientation != .LandscapeLeft && orientation != .LandscapeRight {
                let value = UIInterfaceOrientation.LandscapeLeft.rawValue
                UIDevice.currentDevice().setValue(value, forKey: "orientation")
            }
        }
        
        lblStartTime.font = UIFont(name: "DBLCDTempBlack", size: 18)
        lblEndTime.font = UIFont(name: "DBLCDTempBlack", size: 18)
        lblName.text = asset?.title
        
        player.btnPlay = btnPlay
        player.lblStartTime = lblStartTime
        player.lblEndTime = lblEndTime
        player.progressSlider = lblProgress
        player.toolbarTop = toolbarTop
        player.toolbarBottom = toolbarBottom
        player.endTime = asset?.playbackDuration ?? 0
        
        playAsset(asset!)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.LandscapeLeft, .LandscapeRight]
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .LandscapeLeft
    }
    
    func playAsset(asset: MPMediaItem) {
        self.asset = asset
        self.player.readToPlay(asset.assetURL!)
    }
    
    @IBAction func click_close(sender: UIButton) {
        self.routeBack()
    }
    @IBAction func click_last(sender: UIButton) {
        var index = dataArray.indexesOf(asset!).first!
        index = max(index - 1, 0)
        let video = dataArray[index]
        playAsset(video)
    }
    @IBAction func click_back(sender: UIButton) {
        player.seekAddTime(-20)
        player.delayToolBarHidden()
    }
    @IBAction func click_fast(sender: UIButton) {
        player.seekAddTime(20)
        player.delayToolBarHidden()
    }
    @IBAction func click_next(sender: UIButton) {
        var index = dataArray.indexesOf(asset!).first!
        index = min(index + 1, dataArray.count - 1)
        let video = dataArray[index]
        playAsset(video)
    }
}
