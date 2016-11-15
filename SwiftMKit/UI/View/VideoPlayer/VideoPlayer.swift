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

public class VideoPlayer: NSObject {
    
    public var player: Player
    public weak var viewController: UIViewController!
    public var view: UIView {
        return viewController.view
    }
    public var btnPlay: UIButton? {
        didSet {
            btnPlay?.addTarget(self, action: #selector(click_play(_:)), forControlEvents: .TouchUpInside)
        }
    }
    public var lblStartTime: UILabel?
    public var lblEndTime: UILabel?
    public var progressSlider: UISlider? {
        didSet {
            progressSlider?.addTarget(self, action: #selector(click_slider_touchdown(_:)), forControlEvents: .TouchDown)
            progressSlider?.addTarget(self, action: #selector(click_slider_touchup(_:)), forControlEvents: .TouchUpInside)
            progressSlider?.addTarget(self, action: #selector(click_slider_touchup(_:)), forControlEvents: .TouchUpOutside)
            progressSlider?.addTarget(self, action: #selector(click_slider_valuechanged(_:)), forControlEvents: .ValueChanged)
        }
    }
    public var toolbarTop: UIView?
    public var toolbarBottom: UIView?
    public var url: NSURL?
    public var dragingTimeUnit: Double = 5
    public var dragingVolumneUnit: Double = 1
    public var dragingBrightnessUnit: Double = 1
    public var timeScale: Int32 = 1
    public var startTime: NSTimeInterval = 0 {
        didSet {
            lblStartTime?.text = startTime.formatToTimeMMss()
        }
    }
    public var endTime: NSTimeInterval = 0 {
        didSet {
            lblEndTime?.text = endTime.formatToTimeMMss()
        }
    }
    public var duration: NSTimeInterval {
        return player.maximumDuration
    }
    public var volumeView: MPVolumeView = {
        let view = MPVolumeView()
        view.sizeToFit()
        return view
    }()
    public var volumeSlider: UISlider? {
        return volumeView.subviews.filter { $0 is UISlider }.first as? UISlider
    }
    
    var hideToolBarTime: NSTimeInterval = 0
    var showToolBar: Bool = true {
        didSet {
            if showToolBar == true {
                btnPlay?.hidden = false
                UIView.animateWithDuration(0.4, animations: {
                    self.toolbarTop?.transform = CGAffineTransformIdentity
                    self.toolbarBottom?.transform = CGAffineTransformIdentity
                    }, completion: { _ in
                })
                self.delayToolBarHidden()
            } else {
                if oldValue == showToolBar {
                    return
                }
                btnPlay?.hidden = true
                UIView.animateWithDuration(0.4, animations: {
                    if let toolbarTop = self.toolbarTop {
                        toolbarTop.transform = CGAffineTransformTranslate(toolbarTop.transform, 0, -toolbarTop.size.height-20)
                    }
                    if let toolbarBottom = self.toolbarBottom {
                        toolbarBottom.transform = CGAffineTransformTranslate(toolbarBottom.transform, 0, toolbarBottom.size.height)
                    }
                    }, completion: { _ in
                })
            }
        }
    }
    
    public var playing: Bool {
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
                btnPlay?.selected = true
            } else {
                player.pause()
                showToolBar = true
                btnPlay?.selected = false
            }
        }
    }
    func delayToolBarHidden() {
        hideToolBarTime = NSDate().timeIntervalSince1970 + 2
        Async.main(after: 2) {
            if self.hideToolBarTime > 0 && NSDate().timeIntervalSince1970 > self.hideToolBarTime && !self.dragging {
                self.hideToolBarTime = 0
                self.showToolBar = false
            }
        }
    }
    
    private var doubleTap: Bool = false
    private var dragging: Bool = false
    private var hiddingTime: NSTimeInterval = 0
    private var touchPosition: CGPoint?
    private var restorePlay: Bool = false
    private var panForProgress: Bool = false
    private var panForVolumne: Bool = false
    private var panForBrightness: Bool = false
    
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
        self.player = Player()
        super.init()
        setupUI()
    }
    
    func setupUI() {
        self.player.delegate = self
        self.viewController.addChildViewController(self.player)
        
        self.view.insertSubview(self.player.view, atIndex: 0)
        
        self.player.view.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.player.didMoveToParentViewController(self.viewController)
        
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        self.player.view.addGestureRecognizer(panGestureRecognizer)
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        let doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGestureRecognizer(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.player.view.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    func handleTapGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        doubleTap = false
        Async.main(after: 0.4, block: {
            if self.doubleTap == false {
                self.showToolBar = !self.showToolBar
            }
        })
    }
    func handleDoubleTapGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        doubleTap = true
        playing = !playing
    }
    func handlePanGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            if gestureRecognizer.numberOfTouches() == 0 {
                return
            }
            touchPosition = gestureRecognizer.locationOfTouch(0, inView: self.view)
            panForProgress = false
            panForVolumne = false
            panForBrightness = false
            dragging = true
        case .Changed:
            if !panForProgress && !panForVolumne && !panForBrightness {
                let velocity = gestureRecognizer.velocityInView(self.view)
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
            let position = gestureRecognizer.translationInView(self.view)
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
                var value = UIScreen.mainScreen().brightness + CGFloat(Double(step) * dragingBrightnessUnit)
                value = max(min(value, 1), 0)
                UIScreen.mainScreen().brightness = value
                print("panForBrightness: \(value)")
            }
            touchPosition = gestureRecognizer.locationOfTouch(0, inView: self.view)
            gestureRecognizer.setTranslation(CGPointZero, inView: self.view)
        case .Ended:
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
    func readToPlay(url: NSURL) {
        self.url = url
        hiddingTime = NSDate().timeIntervalSince1970
        player.setUrl(url)
        progressSlider?.value = 0
        startTime = 0
        btnPlay?.selected = false
        showToolBar = true
    }
    func seekAddTime(time: NSTimeInterval) {
        var t = player.currentTime + time
        t = min(max(t, 0), duration)
        player.seekToTime(CMTime(seconds: t, preferredTimescale: timeScale))
    }
    
    func click_play(sender: AnyObject) {
        switch (player.playbackState) {
        case .Stopped:
            player.playFromBeginning()
            btnPlay?.selected = true
            delayToolBarHidden()
        case .Paused:
            playing = true
        case .Playing:
            playing = false
        case .Failed:
            playing = false
        }
    }
    func click_slider_touchdown(sender: AnyObject) {
        dragging = true
        restorePlay = playing
        if playing {
            player.pause()
        }
    }
    func click_slider_touchup(sender: AnyObject) {
        if restorePlay {
            player.playFromCurrentTime()
        }
        delayToolBarHidden()
        dragging = false
    }
    func click_slider_valuechanged(sender: AnyObject) {
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
    
    public func playerReady(player: Player) {
        startTime = player.currentTime
        endTime = duration - startTime
        progressSlider?.value = Float(startTime / duration)
    }
    public func playerPlaybackStateDidChange(player: Player) {}
    public func playerBufferingStateDidChange(player: Player) {}
    public func playerCurrentTimeDidChange(player: Player) {
        if !player.currentTime.isNaN {
            startTime = player.currentTime
            endTime = duration - startTime
            progressSlider?.value = Float(startTime / duration)
        }
    }
    public func playerPlaybackWillStartFromBeginning(player: Player) {
        btnPlay?.selected = true
    }
    public func playerPlaybackDidEnd(player: Player) {
        btnPlay?.selected = false
        showToolBar = true
        startTime = 0
        endTime = duration
        progressSlider?.value = 0
    }

}


extension NSTimeInterval {
    
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
    
    public func applicationWillResignActive(aNotification: NSNotification) {
    }
    
    public func applicationDidEnterBackground(aNotification: NSNotification) {
    }
    
    public func applicationWillEnterForeground(aNoticiation: NSNotification) {
    }
    
}
