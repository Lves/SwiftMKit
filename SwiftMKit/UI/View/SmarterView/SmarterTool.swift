//
//  SmarterViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

public protocol SmarterToolDelegate {
    func routeToEvnSwitch()
}

extension SmarterToolDelegate {
    func routeToEvnSwitch() {}
}

public class SmarterTool: NSObject {
    
    public var delegate: SmarterToolDelegate?
    
    var button:JDJellyButton!
    
    override init() {
        super.init()
        SwiftCrashReport.install(LocalCrashLogReporter)
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = NSTimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 1
        DDLog.addLogger(fileLogger)
    }
    
    func attachToView(view: UIView, homeIcon: String = "icon_st_apple") {
        button = JDJellyButton()
        button.attachtoView(view, mainbutton: UIImage(named: homeIcon)!)
        button.delegate = self
        button.datasource = self
    }

}
extension SmarterTool:JellyButtonDelegate
{
    func JellyButtonHasBeenTap(touch:UITouch,image:UIImage,groupindex:Int,arrindex:Int)
    {
        button.MainButton.closingButtonGroup(expandagain: false)
        if arrindex == 1 {
            delegate?.routeToEvnSwitch()
        } else if arrindex == 0 {
            UIViewController.topController?.routeToName("DDLogViewController")
        } else if arrindex == 2 {
            UIViewController.topController?.routeToName("CrashLogViewController")
        }
    }
    
}

extension SmarterTool:JDJellyButtonDataSource
{
    func groupcount()->Int
    {
        return 1
    }
    func imagesource(forgroup groupindex:Int) -> [UIImage]
    {
        return [UIImage(named: "icon_st_file")!, UIImage(named: "icon_st_switch")!, UIImage(named: "icon_st_bug")!]
    }
}
