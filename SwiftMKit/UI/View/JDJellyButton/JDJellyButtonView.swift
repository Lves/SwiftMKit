//
//  JDJellyButtonView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 06/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//


import UIKit

protocol JellyButtonDelegate {
    func JellyButtonHasBeenTap(touch:UITouch,image:UIImage,groupindex:Int,arrindex:Int)
}

extension JellyButtonDelegate{
    func JellyButtonHasBeenTap(touch:UITouch,image:UIImage,groupindex:Int,arrindex:Int)
    {
        
    }
}



class JDJellyButtonView:UIView
{
    var tapdelegate:JellyButtonDelegate?
    var dependingMainButton:JDJellyMainButton?
    var imgView:UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect,BGColor:UIColor) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 0.4 * self.frame.width
        self.backgroundColor = BGColor
    }
    
    init(frame: CGRect,bgimg:UIImage) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 0.4 * self.frame.width
        imgView = UIImageView(image: bgimg)
        
        imgView?.frame = self.bounds
        imgView?.contentMode = .scaleAspectFit
        imgView?.mBorderColor = UIColor.black
        imgView?.mBorderWidth = 2
        imgView?.mCornerRadius = (imgView?.size.width ?? 0) / 2
        self.addSubview(imgView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let image = self.imgView?.image
        let groupindex = dependingMainButton?.getGroupIndex()
        let arrindex = dependingMainButton?.getJellyButtonIndex(jelly: self)
        print("\(groupindex ?? 0),\(arrindex ?? 0)")
        tapdelegate?.JellyButtonHasBeenTap(touch: touches.first!,image: image!,groupindex: groupindex!,arrindex: arrindex!)
    }
    
    
}
