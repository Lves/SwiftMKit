//
//  PickerTextField.swift
//  SwiftMKitDemo
//
//  Created by lixingle on 2017/2/24.
//  Copyright © 2017年 cdts. All rights reserved.
//

import UIKit


struct PickerFieldConst{
    static let ScreenW: CGFloat = UIScreen.mainScreen().bounds.w
    static let ScreenH: CGFloat = UIScreen.mainScreen().bounds.h
    static let PickerViewH :CGFloat = 210
    static let ToolBarH :CGFloat = 44
    static let ToolBarBackgrountColor = UIColor(hex6: 0xefeff4)
}

@objc
public protocol PickerTextFieldDelegate : class {
    func pickerTextField(pickerTextField: PickerTextField, didSelectRow row: Int)
}


public class PickerTextField: UITextField ,UIPickerViewDelegate,UIPickerViewDataSource{
    var dataArray:[String]?            //PIcker的数据源
    var defaultIndex:Int = 0           //Picker默认显示dataArray下标
    var defaultComponent:Int = 0
    var showPickerDuration:NSTimeInterval = 0.5
    var rowHeight:CGFloat = 50
    private var textButton: UIButton?
    public weak var pickerTextFieldDelegate: PickerTextFieldDelegate?

    lazy var coverView:UIView = {
        let cover = UIView(frame:CGRectMake(0,0 , PickerFieldConst.ScreenW, PickerFieldConst.ScreenH))
        cover.backgroundColor = UIColor(hex6: 0x000000,alpha: 0.35)
        let tapGuest = UITapGestureRecognizer(target: self, action: #selector(PickerTextField.tapCover))
        cover.addGestureRecognizer(tapGuest)
        
        cover.addSubview(self.toolView)
        return cover
    }()
    
    lazy var pickerView:UIPickerView = {
        let picker = UIPickerView(frame: CGRectMake(0,0 , PickerFieldConst.ScreenW, PickerFieldConst.PickerViewH))
        picker.backgroundColor = UIColor.whiteColor()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    lazy var cancleButton:UIButton = {
        let button = UIButton()
        button.setTitle("完成", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.addTarget(self, action: #selector(PickerTextField.tapCancle), forControlEvents: .TouchUpInside)
        return button
    }()
    lazy var toolView:UIView = {
        let toolView = UIView(frame: CGRectMake(0, PickerFieldConst.ScreenH, PickerFieldConst.ScreenW, PickerFieldConst.ToolBarH+self.pickerView.h))
        toolView.backgroundColor = PickerFieldConst.ToolBarBackgrountColor
        self.cancleButton.frame = CGRectMake(PickerFieldConst.ScreenW - 55, 0, 40, PickerFieldConst.ToolBarH)
        toolView.addSubview(self.cancleButton)
        self.pickerView.y = self.cancleButton.h
        toolView.addSubview(self.pickerView)
       return toolView
    }()
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
    
    
    private func setUpUI(){
        textButton = UIButton(frame: self.bounds)
        textButton?.addTarget(self, action: #selector(PickerTextField.showPicker), forControlEvents: .TouchUpInside)
        self.addSubview(textButton!)
    }
    
    @objc private func showPicker()  {
      
        
        UIApplication.sharedApplication().keyWindow?.addSubview(self.coverView)
        
        UIView.animateWithDuration(showPickerDuration, animations: {
            self.toolView.y =  self.toolView.y - self.toolView.h
        }) { (sucess) in
            if self.text?.length == 0 { //为设置显示第一个
                self.text = self.dataArray?[safe:self.defaultIndex]
            }else { //找到滑动到该cell
                let index = self.dataArray?.indexOf(self.text ?? "") ?? self.defaultIndex
                self.pickerView.selectRow(index, inComponent: self.defaultComponent, animated: true)
            }
        }
        
    }
    
    //MARK:
    @objc private func tapCover()  {
        self.hidenPicker()
    }
    @objc private func tapCancle()  {
        self.hidenPicker()
    }
    private func hidenPicker()  {
        UIView.animateWithDuration(showPickerDuration, animations: {
            self.toolView.y =  self.toolView.y + self.toolView.h
        }) { (sucess) in
            self.coverView.removeFromSuperview()
        }
    }
}

extension PickerTextField {
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return dataArray?.count > 0 ? 1 : 0
    }
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (dataArray?.count ?? 0)
    }
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataArray?[safe:row] ?? ""
    }
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = dataArray?[safe:row] ?? ""
        self.pickerTextFieldDelegate?.pickerTextField(self, didSelectRow: row)
    }
    public func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    
}
