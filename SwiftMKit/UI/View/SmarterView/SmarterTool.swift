//
//  SmarterViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//

import UIKit

public protocol SmarterToolDelegate {
    func routeToEvnSwitch()
}

extension SmarterToolDelegate {
    func routeToEvnSwitch() {}
}

public class SmarterTool {
    
    public var delegate: SmarterToolDelegate?
    
    var button:JDJellyButton!
    
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
