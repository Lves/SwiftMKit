//
//  BaseCaptchaImageView.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2017/6/28.
//  Copyright © 2017年 cdts. All rights reserved.
//

import UIKit
import ReactiveSwift

class BaseCaptchaImageView: UIButton {
    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    func setupUI() {
        setTitle("", for: UIControlState())
        isUserInteractionEnabled = true
        self.addTarget(self, action: #selector(BaseCaptchaImageView.refresh), for: .touchUpInside)
        indicator.center = self.center
        indicator.hidesWhenStopped = true
        indicator.isHidden = false
        self.addSubview(indicator)
        refresh()
    }
    
    func getApi() -> SignalProducer<NetApiProtocol, NetError>? {
        return nil
    }
    
    func refresh() {
        setTitle("", for: UIControlState())
        indicator.startAnimating()
        setBackgroundImage(nil, for: UIControlState())
        isUserInteractionEnabled = false
        getApi()?.on(failed: { [weak self] error in
            self?.isUserInteractionEnabled = true
            self?.indicator.stopAnimating()
            self?.setTitle("点击刷新", for: .normal)
            },value: { [weak self] api in
                if let imgData = api.response?.data {
                    self?.setBackgroundImage(UIImage(data: imgData), for: .normal)
                }
                self?.isUserInteractionEnabled = true
                self?.indicator.stopAnimating()
                
        }).start()
    }
    
}
