//
//  MKDataNetworkImagesViewModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CocoaLumberjack

class MKNetworkRequestDetailViewModel: BaseViewModel {
    
    var _viewController: MKNetworkRequestDetailViewController? {
        get { return self.viewController as? MKNetworkRequestDetailViewController }
    }
    var photoId: String? {
        get { return _viewController?.photoId }
    }
    var photo = MutableProperty<PX500PopularPhotoModel?>(nil)
    var isLike = MutableProperty<Bool>(false)
    lazy var actionLike: Action<AnyObject, AnyObject, NSError> = {
        let action = Action<AnyObject, AnyObject, NSError> { [weak self] input in
            return SignalProducer { [weak self] (sink, _) in
                if let like = self?.isLike.value {
                    self?.isLike.value = !like
                }
                sink.sendNext(input)
                sink.sendCompleted()
            }
        }
        action.values.observeNext { values in
            DDLogVerbose("\(values)")
        }
        action.errors.observeNext { error in
            DDLogError("\(error)")
        }
        return action
    }()
    
    private var signalPX500Photo: SignalProducer<PX500PhotoDetailApiData, NetError> {
        get {
            return PX500PhotoDetailApiData(photoId: photoId!).setIndicator(self.indicator, view: self.view).signal().on(
                next: { [weak self] data in
                    if let photo = data.photo {
                        self?.photo.value = photo
                    }
                },
                failed: { [weak self] error in
                    self?.showTip(error.message)
            })
        }
    }
    override func fetchData() {
        signalPX500Photo.start()
    }
}
