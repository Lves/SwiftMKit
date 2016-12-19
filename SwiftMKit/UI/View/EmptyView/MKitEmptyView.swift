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
import ReactiveSwift

open class MKitEmptyView: NSObject {
    open var title: String {
        didSet {
            self.view.lblTitle.text = title
        }
    }
    open var image: UIImage? {
        didSet {
            self.view.imgView.image = image
            self.view.imgView.size = image?.size ?? CGSize.zero
        }
    }
    open var titleLabel: UILabel {
        return self.view.lblTitle
    }
    open var imageView: UIImageView {
        return self.view.imgView
    }
    open var showed = MutableProperty<Bool>(false)
    open var yOffset: CGFloat
    open var view: BaseKitEmptyView
    open var inView: UIView
    
    public init(title: String, image: UIImage?, yOffset: CGFloat, view: BaseKitEmptyView, inView: UIView) {
        self.title = title
        self.image = image
        self.yOffset = yOffset
        self.view = view
        self.inView = inView
        super.init()
    }
    open func show(title: String? = nil, image: UIImage? = nil, yOffset: CGFloat? = nil, inView: UIView? = nil) {
        if let title = title { self.title = title }
        if let image = image { self.image = image }
        if let yOffset = yOffset { self.yOffset = yOffset }
        if let inView = inView { self.inView = inView }
        view.removeFromSuperview()
        self.inView.addSubview(self.view)
        self.view.snp.makeConstraints { [unowned self] (make) in
            make.centerX.equalTo(self.inView)
            make.centerY.equalTo(self.inView).offset(self.yOffset)
        }
        DDLogInfo("Show Empty View")
        showed.value = true
    }
    open func hide() {
        view.removeFromSuperview()
        DDLogInfo("Hide Empty View")
        showed.value = false
    }
}
