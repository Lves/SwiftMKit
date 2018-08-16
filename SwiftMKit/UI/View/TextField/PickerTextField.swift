//
//  PickerTextField.swift
//  SwiftMKitDemo
//
//  Created by lixingle on 2017/2/24.
//  Copyright © 2017年 cdts. All rights reserved.
//

import UIKit


struct PickerFieldConst{
    static let ScreenW: CGFloat = UIScreen.main.bounds.w
    static let ScreenH: CGFloat = UIScreen.main.bounds.h
    static let PickerViewH :CGFloat = 210
    static let ToolBarH :CGFloat = 44
    static let ToolBarBackgrountColor = UIColor(hex6: 0xefeff4)
}

public protocol PickerTextFieldDelegate : class {
    func pickerTextField(_ pickerTextField: PickerTextField, didSelectRow row: Int)
    func pickerTextField(_ pickerTextField: PickerTextField, formatString string:String ,forRow row:Int) -> String?
}

extension PickerTextFieldDelegate {
    func pickerTextField(_ pickerTextField: PickerTextField, formatString string:String ,forRow row:Int) -> String? {
        return nil
    }
}


public class PickerTextField: UITextField ,UIPickerViewDelegate,UIPickerViewDataSource {
    public var dataArray:[String]?            //PIcker的数据源
    public var defaultIndex:Int = 0           //Picker默认显示dataArray下标
    public var defaultComponent:Int = 0
    public var showPickerDuration:TimeInterval = 0.5
    public var rowHeight:CGFloat = 50
    private var textButton: UIButton?
    fileprivate var selectedRow:Int = 0
    public weak var pickerTextFieldDelegate: PickerTextFieldDelegate?
    
    public lazy var coverView:UIView = {
        let cover = UIView(frame:CGRect(x: 0, y: 0 , w: PickerFieldConst.ScreenW, h: PickerFieldConst.ScreenH))
        cover.backgroundColor = UIColor(hex6: 0x000000,alpha: 0.35)
        let tapGuest = UITapGestureRecognizer(target: self, action: #selector(PickerTextField.tapCover))
        cover.addGestureRecognizer(tapGuest)
        
        cover.addSubview(self.toolView)
        return cover
    }()
    
    public lazy var pickerView:UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0 , w: PickerFieldConst.ScreenW, h: PickerFieldConst.PickerViewH))
        picker.backgroundColor = UIColor.white
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    public lazy var cancleButton:UIButton = {
        let button = UIButton()
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(PickerTextField.tapCancle), for: .touchUpInside)
        return button
    }()
    public lazy var toolView:UIView = {
        let toolView = UIView(frame: CGRect(x: 0, y: PickerFieldConst.ScreenH, w: PickerFieldConst.ScreenW, h: PickerFieldConst.ToolBarH+self.pickerView.h))
        toolView.backgroundColor = PickerFieldConst.ToolBarBackgrountColor
        self.cancleButton.frame = CGRect(x: PickerFieldConst.ScreenW - 55, y: 0, w: 40, h: PickerFieldConst.ToolBarH)
        toolView.addSubview(self.cancleButton)
        self.pickerView.y = self.cancleButton.h
        toolView.addSubview(self.pickerView)
        return toolView
    }()
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
    
    
    private func setUpUI(){
        textButton = UIButton(frame: self.bounds)
        textButton?.addTarget(self, action: #selector(PickerTextField.showPicker), for: .touchUpInside)
        self.addSubview(textButton!)
    }
    
    @objc private func showPicker()  {
        UIApplication.shared.keyWindow?.addSubview(self.coverView)
        
        UIView.animate(withDuration: showPickerDuration, animations: {
            self.toolView.y =  self.toolView.y - self.toolView.h
        }) { (sucess) in
            if self.text?.length == 0 { //未设置显示第一个
                let nextIndexString = self.dataArray?[safe:self.defaultIndex] ?? ""
                if let string = self.pickerTextFieldDelegate?.pickerTextField(self, formatString: nextIndexString ,forRow: self.defaultIndex) {
                    self.text = string
                }else {
                    self.text = nextIndexString
                }
            }else { //找到滑动到该cell
                self.pickerView.selectRow(self.selectedRow, inComponent: self.defaultComponent, animated: true)
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
        UIView.animate(withDuration: showPickerDuration, animations: {
            self.toolView.y =  self.toolView.y + self.toolView.h
        }) { (sucess) in
            self.coverView.removeFromSuperview()
        }
    }
}

extension PickerTextField {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (dataArray?.count ?? 0) > 0 ? 1 : 0
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (dataArray?.count ?? 0)
    }
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let nextIndexString = dataArray?[safe:row] ?? ""
        if let string = self.pickerTextFieldDelegate?.pickerTextField(self, formatString: nextIndexString ,forRow: row) {
            return string
        }else {
            return nextIndexString
        }
    }
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        let nextIndexString = dataArray?[safe:row] ?? ""
        if let string = self.pickerTextFieldDelegate?.pickerTextField(self, formatString: nextIndexString ,forRow: row) {
            self.text = string
        }else {
            self.text = nextIndexString
        }
        self.pickerTextFieldDelegate?.pickerTextField(self, didSelectRow: row)
    }
    public func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    
}
