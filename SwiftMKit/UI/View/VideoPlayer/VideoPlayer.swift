//
//  VideoPlayer.swift
//  SwiftMKitDemo
//
//  Created by Mao on 15/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Player
import SnapKit
import CoreMedia
import CocoaLumberjack
import MediaPlayer
import AVKit

open class VideoPlayer: NSObject {
    
    open var player: Player
    open weak var viewController: UIViewController!
    open var view: UIView {
        return viewController.view
    }
    open var btnPlay: UIButton? {
        didSet {
            btnPlay?.addTarget(self, action: #selector(click_play(_:)), for: .touchUpInside)
        }
    }
    open var lblStartTime: UILabel?
    open var lblEndTime: UILabel?
    open var progressSlider: UISlider? {
        didSet {
            progressSlider?.addTarget(self, action: #selector(click_slider_touchdown(_:)), for: .touchDown)
            progressSlider?.addTarget(self, action: #selector(click_slider_touchup(_:)), for: .touchUpInside)
            progressSlider?.addTarget(self, action: #selector(click_slider_touchup(_:)), for: .touchUpOutside)
            progressSlider?.addTarget(self, action: #selector(click_slider_valuechanged(_:)), for: .valueChanged)
        }
    }
    open var toolbarTop: UIView?
    open var toolbarBottom: UIView?
    open var url: URL?
    open var dragingTimeUnit: Double = 5
    open var dragingVolumneUnit: Double = 1
    open var dragingBrightnessUnit: Double = 1
    open var timeScale: Int32 = 1
    open var startTime: TimeInterval = 0 {
        didSet {
            lblStartTime?.text = startTime.formatToTimeMMss()
        }
    }
    open var endTime: TimeInterval = 0 {
        didSet {
            lblEndTime?.text = endTime.formatToTimeMMss()
        }
    }
    open var duration: TimeInterval {
        return player.maximumDuration
    }
    open var volumeView: MPVolumeView = {
        let view = MPVolumeView()
        view.sizeToFit()
        return view
    }()
    open var volumeSlider: UISlider? {
        return volumeView.subviews.filter { $0 is UISlider }.first as? UISlider
    }
    
    var hideToolBarTime: TimeInterval = 0
    var showToolBar: Bool = true {
        didSet {
            if showToolBar == true {
                btnPlay?.isHidden = false
                UIView.animate(withDuration: 0.4, animations: {
                    self.toolbarTop?.transform = CGAffineTransform.identity
                    self.toolbarBottom?.transform = CGAffineTransform.identity
                    }, completion: { _ in
                })
                self.delayToolBarHidden()
            } else {
                if oldValue == showToolBar {
                    return
                }
                btnPlay?.isHidden = true
                UIView.animate(withDuration: 0.4, animations: {
                    if let toolbarTop = self.toolbarTop {
                        toolbarTop.transform = (toolbarTop.transform).translatedBy(x: 0, y: -toolbarTop.size.height-20)
                    }
                    if let toolbarBottom = self.toolbarBottom {
                        toolbarBottom.transform = (toolbarBottom.transform).translatedBy(x: 0, y: toolbarBottom.size.height)
                    }
                    }, completion: { _ in
                })
            }
        }
    }
    
    open var playing: Bool {
        get {
            return player.playbackState == .Playing
        }
        set {
            if playing == newValue {
                return
            }
            if newValue {
                player.playFromCurrentTime()
                delayToolBarHidden()
                btnPlay?.isSelected = true
            } else {
                player.pause()
                showToolBar = true
                btnPlay?.isSelected = false
            }
        }
    }
    func delayToolBarHidden() {
        hideToolBarTime = Date().timeIntervalSince1970 + 2
        Async.main(after: 2) {
            if self.hideToolBarTime > 0 && Date().timeIntervalSince1970 > self.hideToolBarTime && !self.dragging {
                self.hideToolBarTime = 0
                self.showToolBar = false
            }
        }
    }
    
    fileprivate var doubleTap: Bool = false
    fileprivate var dragging: Bool = false
    fileprivate var hiddingTime: TimeInterval = 0
    fileprivate var touchPosition: CGPoint?
    fileprivate var restorePlay: Bool = false
    fileprivate var panForProgress: Bool = false
    fileprivate var panForVolumne: Bool = false
    fileprivate var panForBrightness: Bool = false
    
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
        self.player = Player()
        super.init()
        setupUI()
    }
    
    func setupUI() {
        self.player.delegate = self
        self.viewController.addChildViewController(self.player)
        
        self.view.insertSubview(self.player.view, at: 0)
        
        self.player.view.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.player.didMove(toParentViewController: self.viewController)
        
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        self.player.view.addGestureRecognizer(panGestureRecognizer)
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        let doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGestureRecognizer(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.player.view.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    func handleTapGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        doubleTap = false
        Async.main(after: 0.4, {
            if self.doubleTap == false {
                self.showToolBar = !self.showToolBar
            }
        })
    }
    func handleDoubleTapGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        doubleTap = true
        playing = !playing
    }
    func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if gestureRecognizer.numberOfTouches == 0 {
                return
            }
            touchPosition = gestureRecognizer.location(ofTouch: 0, in: self.view)
            panForProgress = false
            panForVolumne = false
            panForBrightness = false
            dragging = true
        case .changed:
            if !panForProgress && !panForVolumne && !panForBrightness {
                let velocity = gestureRecognizer.velocity(in: self.view)
                if velocity.x == 0 && velocity.y == 0 {
                    return
                }
                if abs(velocity.y) <= 2 * abs(velocity.x) {
                    restorePlay = playing
                    player.pause()
                    panForProgress = true
                    panForVolumne = false
                    panForBrightness = false
                } else {
                    panForProgress = false
                    if touchPosition!.x <= view.size.width / 2 {
                        panForBrightness = true
                        panForVolumne = false
                    } else {
                        panForBrightness = false
                        panForVolumne = true
                    }
                }
            }
            let position = gestureRecognizer.translation(in: self.view)
            let step = -position.y / self.view.size.height
            if panForProgress {
                let step = position.x / self.view.size.width
                print("step: \(step)")
                var offsetTime = Double(step) * dragingTimeUnit
                if offsetTime < 1 && offsetTime > -1 && offsetTime != 0 {
                    offsetTime = (offsetTime > 0 ? 1: -1)
                }
                print("offsetTime: \(offsetTime)")
                seekAddTime(offsetTime)
                print("currentTime: \(player.currentTime)")
            } else if panForVolumne {
                print("step: \(step)")
                var value = (volumeSlider?.value ?? 0) + Float(Double(step) * dragingVolumneUnit)
                value = max(min(value, 1), 0)
                volumeSlider?.value = value
                print("panForVolumne: \(value)")
                
            } else if panForBrightness {
                print("step: \(step)")
                var value = UIScreen.main.brightness + CGFloat(Double(step) * dragingBrightnessUnit)
                value = max(min(value, 1), 0)
                UIScreen.mainScreen().brightness = value
                print("panForBrightness: \(value)")
            }
            touchPosition = gestureRecognizer.location(ofTouch: 0, in: self.view)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        case .ended:
            if panForProgress {
                if restorePlay {
                    player.playFromCurrentTime()
                }
            }
            panForProgress = false
            panForVolumne = false
            panForBrightness = false
            restorePlay = false
            touchPosition = nil
            delayToolBarHidden()
            dragging = false
            return
            
        default:
            break
        }
    }
    func readToPlay(_ url: URL) {
        self.url = url
        hiddingTime = Date().timeIntervalSince1970
        player.setUrl(url)
        progressSlider?.value = 0
        startTime = 0
        btnPlay?.isSelected = false
        showToolBar = true
    }
    func seekAddTime(_ time: TimeInterval) {
        var t = player.currentTime + time
        t = min(max(t, 0), duration)
        player.seekToTime(CMTime(seconds: t, preferredTimescale: timeScale))
    }
    
    func click_play(_ sender: AnyObject) {
        switch (player.playbackState) {
        case .stopped:
            player.playFromBeginning()
            btnPlay?.isSelected = true
            delayToolBarHidden()
        case .paused:
            playing = true
        case .playing:
            playing = false
        case .failed:
            playing = false
        }
    }
    func click_slider_touchdown(_ sender: AnyObject) {
        dragging = true
        restorePlay = playing
        if playing {
            player.pause()
        }
    }
    func click_slider_touchup(_ sender: AnyObject) {
        if restorePlay {
            player.playFromCurrentTime()
        }
        delayToolBarHidden()
        dragging = false
    }
    func click_slider_valuechanged(_ sender: AnyObject) {
        if let value = progressSlider?.value {
            let time = Double(value) * duration
            player.seekToTime(CMTime(seconds: time, preferredTimescale: timeScale))
        }
    }
    
    deinit {
        DDLogError("Deinit")
    }
}

extension VideoPlayer: PlayerDelegate {
    
    public func playerReady(_ player: Player) {
        startTime = player.currentTime
        endTime = duration - startTime
        progressSlider?.value = Float(startTime / duration)
    }
    public func playerPlaybackStateDidChange(_ player: Player) {}
    public func playerBufferingStateDidChange(_ player: Player) {}
    public func playerCurrentTimeDidChange(_ player: Player) {
        if !player.currentTime.isNaN {
            startTime = player.currentTime
            endTime = duration - startTime
            progressSlider?.value = Float(startTime / duration)
        }
    }
    public func playerPlaybackWillStartFromBeginning(_ player: Player) {
        btnPlay?.isSelected = true
    }
    public func playerPlaybackDidEnd(_ player: Player) {
        btnPlay?.isSelected = false
        showToolBar = true
        startTime = 0
        endTime = duration
        progressSlider?.value = 0
    }

}


extension TimeInterval {
    
    func formatToTimeMMss() -> String {
        let seconds = String(format: "%02d", Int(self) % 60)
        let mins = String(format: "%02d", Int(self) / 60)
        if (mins.toInt() ?? 0) >= 100 {
            let hours = String(format: "%02d", Int(self) / 3600)
            let mins = String(format: "%02d", Int(self) / 60 % 60)
            return "\(hours):\(mins):\(seconds)"
        }
        return "\(mins):\(seconds)"
    }
}


extension Player {
    
    public func applicationWillResignActive(_ aNotification: NSNotification) {
    }
    
    public func applicationDidEnterBackground(_ aNotification: NSNotification) {
    }
    
    public func applicationWillEnterForeground(_ aNoticiation: NSNotification) {
    }
    
}
