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
    var runningTasks: [URLSessionTask] { get set }
    func bindTask(_ task: URLSessionTask, view: UIView?, text: String?)
}
