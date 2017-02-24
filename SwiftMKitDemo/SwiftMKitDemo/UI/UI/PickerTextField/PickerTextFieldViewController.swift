//
//  PickerTextFieldViewController.swift
//  SwiftMKitDemo
//
//  Created by lixingle on 2017/2/24.
//  Copyright © 2017年 cdts. All rights reserved.
//

import UIKit

class PickerTextFieldViewController: UIViewController,PickerTextFieldDelegate {

    @IBOutlet weak var pickerTextField: PickerTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerTextField.dataArray = ["刘德华","吴彦祖","梁朝伟","谢霆锋"]
        pickerTextField.pickerTextFieldDelegate = self
    }
    
    func pickerTextField(pickerTextField: PickerTextField, didSelectRow row: Int) {
        print("选中\(row)")
    }


}
