//
//  EmptyView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ReactiveCocoa

public class MKitEmptyView: NSObject {
    public var title: String {
        didSet {
            self.view.lblTitle.text = title
        }
    }
    public var image: UIImage? {
        didSet {
            self.view.imgView.image = image
            self.view.imgView.size = image?.size ?? CGSizeZero
        }
    }
    public var titleLabel: UILabel {
        return self.view.lblTitle
    }
    public var imageView: UIImageView {
        return self.view.imgView
    }
    public var showed = MutableProperty<Bool>(false)
    public var yOffset: CGFloat
    public var view: BaseKitEmptyView
    public var inView: UIView
    
    public init(title: String, image: UIImage?, yOffset: CGFloat, view: BaseKitEmptyView, inView: UIView) {
        self.title = title
        self.image = image
        self.yOffset = yOffset
        self.view = view
        self.inView = inView
        super.init()
    }
    public func show(title title: String? = nil, image: UIImage? = nil, yOffset: CGFloat? = nil, inView: UIView? = nil) {
        if let title = title { self.title = title }
        if let image = image { self.image = image }
        if let yOffset = yOffset { self.yOffset = yOffset }
        if let inView = inView { self.inView = inView }
        view.removeFromSuperview()
        self.inView.addSubview(self.view)
        self.view.snp_makeConstraints { [unowned self] (make) in
            make.centerX.equalTo(self.inView)
            make.centerY.equalTo(self.inView).offset(self.yOffset)
        }
        DDLogInfo("Show Empty View")
        showed.value = true
    }
    public func hide() {
        view.removeFromSuperview()
        DDLogInfo("Hide Empty View")
        showed.value = false
    }
}
