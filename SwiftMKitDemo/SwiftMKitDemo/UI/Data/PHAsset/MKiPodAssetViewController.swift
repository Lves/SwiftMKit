//
//  MKiPodVideoViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 14/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import MediaPlayer

class MKiPodAssetViewController: BaseListViewController {
    
    struct InnerConst {
        static let CellIdentifier = "MKiPodAssetTableViewCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var source: [String: [MPMediaItem]] = [:]
    
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
        if let bvc = segue.destination as? MKiPodVideoDetailViewController,
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
            if type == .movie {
                source["Movie"]?.append(item)
            } else {
                source["Song"]?.append(item)
            }
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return source["Movie"]?.count ?? 0
        }
        return source["Song"]?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, w: self.view.w, h: 40))
        view.backgroundColor = UIColor.lightGray
        let label = UILabel(frame: view.bounds)
        label.text = (section == 0 ? "Movie" : "Song")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.x = 10
        view.addSubview(label)
        return view
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InnerConst.CellIdentifier, for: indexPath)
        let section = (indexPath.section == 0 ? "Movie" : "Song")
        if let asset = source[section]?[indexPath.row] {
            cell.textLabel?.text = asset.title
//            cell.detailTextLabel?.text = asset.playbackDuration.formatToTimeMMss()
        } else {
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if let asset = source["Movie"]?[indexPath.row] {
                self.performSegue(withIdentifier: "routeToVideo", sender: asset)
            }
        } else {
            if let asset = source["Song"]?[indexPath.row] {
                self.performSegue(withIdentifier: "routeToSong", sender: asset)
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
    
//    lazy var player: VideoPlayer = { return VideoPlayer(viewController: self) }()
    
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
        lblName.text = asset?.title
        
//        player.btnPlay = btnPlay
//        player.lblStartTime = lblStartTime
//        player.lblEndTime = lblEndTime
//        player.progressSlider = lblProgress
//        player.toolbarTop = toolbarTop
//        player.toolbarBottom = toolbarBottom
//        player.endTime = asset?.playbackDuration ?? 0
        
        playAsset(asset!)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    func playAsset(_ asset: MPMediaItem) {
        self.asset = asset
//        self.player.readToPlay(asset.assetURL!)
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
//        player.seekAddTime(-20)
//        player.delayToolBarHidden()
    }
    @IBAction func click_fast(_ sender: UIButton) {
//        player.seekAddTime(20)
//        player.delayToolBarHidden()
    }
    @IBAction func click_next(_ sender: UIButton) {
        var index = dataArray.indexesOf(asset!).first!
        index = min(index + 1, dataArray.count - 1)
        let video = dataArray[index]
        playAsset(video)
    }
}
