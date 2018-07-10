//
//  MKEmptyViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 17/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKNormalEmptyViewController: BaseViewController {
    let a = A()

    override func setupUI() {
        super.setupUI()
        loadData()
        a.b = B()
        a.b?.a = a
    }
    override func loadData() {
        super.loadData()
        
        AdApi(type: .home).setIndicator(indicator: taskIndicator).signal().on(failed: { [weak self] (error) in
            print(error)
            self?.showTip(error.message)
        }) { [weak self] api in
            print("yes!!!")
            }.start()
//        LoginApi(mobile: "18600586544", password: "123123").setIndicator(indicator: taskIndicator)
//            .signal().on(failed: { (error) in
//                print(error)
//            }) { [weak self] api in
//                LoginService.accessKey = api.accessKey!
//                LoginService.token = api.token!
//                LoginService.username = api.username!
//                LoanUserInfo().setIndicator(indicator: self?.taskIndicator).signal().on(failed: { (error) in
//                }) { api in
//                    print("yes!!!")
//                    }.start()
//        }.start()
        emptyView?.show()
    }

}
class A {
    var b: B?
}
class B {
    var a: A?
}
