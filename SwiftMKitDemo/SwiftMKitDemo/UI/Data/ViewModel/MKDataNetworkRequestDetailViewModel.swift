//
//  MKDataNetworkImagesViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MKDataNetworkRequestDetailViewModel: BaseViewModel {
    
    var _viewController: MKDataNetworkRequestDetailViewController? {
        get { return self.viewController as? MKDataNetworkRequestDetailViewController }
    }
    var photoId: String? {
        get { return _viewController?.photoId }
    }
    
    var signalPX500Photo: SignalProducer<PX500PhotoDetailApiData, NSError> {
        get {
            return PX500PhotoDetailApiData(photoId: photoId!).setIndicator(self.viewController).signal().on(
                next: { [weak self] data in
                    if let photo = data.photo {
                    }
                },
                failed: { error in
            })
        }
    }
    override func fetchData() {
        signalPX500Photo.start()
    }
}
