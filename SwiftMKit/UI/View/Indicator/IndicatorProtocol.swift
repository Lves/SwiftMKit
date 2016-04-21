//
//  IndicatorProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

public protocol IndicatorProtocol : class {
    func bindTask(task: NSURLSessionTask, view: UIView, text: String?)
}
public protocol IndicatorListProtocol: class {
    func bindTaskForList(task: NSURLSessionTask)
}