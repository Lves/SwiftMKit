//
//  NumberKeyboard.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import CocoaLumberjack
import IQKeyboardManager

public struct NumberKeyboardUITheme {
    var viewBackgroundColor: UIColor
    var viewLineColor: UIColor
    var viewEnterColor: UIColor
    var viewDelColor: UIColor
    var viewNumberColor: UIColor
    var viewEnterHiglightColor: UIColor
    var viewDelHiglightColor: UIColor
    var viewNumberHiglightColor: UIColor
    var viewDelImage: String = ""
    var viewScreenImage: String = ""
}

open class NumberKeyboard: UIView, NumberKeyboardProtocol {
    
    struct Theme {
        static let DefaultTheme: NumberKeyboardUITheme = NumberKeyboardUITheme(
            viewBackgroundColor: UIColor(hex6: 0x8C8C8C),
            viewLineColor: UIColor(hex6: 0xDCDCDC),
            viewEnterColor: UIColor(hex6: 0xFD734C),
            viewDelColor: UIColor(hex6: 0xFFFFFF),
            viewNumberColor: UIColor(hex6: 0xFFFFFF),
            viewEnterHiglightColor: UIColor(hex6: 0xFD734C),
            viewDelHiglightColor: UIColor(hex6: 0xC0C7D4),
            viewNumberHiglightColor: UIColor(hex6: 0xC0C7D4),
            viewDelImage: "kb_keyboard_view_del",
            viewScreenImage: "kb_keyboard_view_screen")
    }

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    @IBOutlet weak var btn8: UIButton!
    @IBOutlet weak var btn9: UIButton!
    @IBOutlet weak var btnDot: UIButton!
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var btnKey: UIButton!
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    
    @IBOutlet var lines: [UIView]!
    var buttonNumbers: [UIButton] {
        get {
            return [btn0,btn1,btn2,btn3,btn4,btn5,btn6,btn7,btn8,btn9]
        }
    }
    
    open var type: NumberKeyboardType = .normal
    open var textField: UITextField?
    open var text: String = ""
    open var enableAutoToolbar = true {
        willSet {
            IQKeyboardManager.shared().isEnableAutoToolbar = newValue
        }
    }
    
    open static func keyboard(_ textField: UITextField, type: NumberKeyboardType = .normal) -> NumberKeyboard {
        return keyboard(textField, type: type, style: .default)
    }
    open static func keyboard(_ textField: UITextField, type: NumberKeyboardType = .normal, style: NumberKeyboardStyle) -> NumberKeyboard {
        return keyboard(textField, type: type, theme: Theme.DefaultTheme)
    }
    open static func keyboard(_ textField: UITextField, type: NumberKeyboardType = .normal, theme: NumberKeyboardUITheme) -> NumberKeyboard {
        let view = Bundle.main.loadNibNamed("NumberKeyboard", owner: self, options: nil)?.first as? NumberKeyboard
        view?.textField = textField
        view?.type = type
        view?.setupUI(theme)
        //iOS11 解决高度还是之前键盘高度的问题。暂时不打开，有人提bug再来解决。
//        view?.translatesAutoresizingMaskIntoConstraints = false
        return view!
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    open func clear() {
        text = ""
    }
    fileprivate func setupUI(_ theme: NumberKeyboardUITheme) {
        btnDel.setBackgroundImage(UIImage(color: theme.viewDelColor), for: UIControlState())
        btnOk.setBackgroundImage(UIImage(color: theme.viewEnterColor), for: UIControlState())
        btnKey.setBackgroundImage(UIImage(color: theme.viewNumberColor), for: UIControlState())
        btnDel.setBackgroundImage(UIImage(color: theme.viewDelHiglightColor), for: .highlighted)
        btnOk.setBackgroundImage(UIImage(color: theme.viewEnterHiglightColor), for: .highlighted)
        btnKey.setBackgroundImage(UIImage(color: theme.viewNumberHiglightColor), for: .highlighted)
        btnKey.setImage(UIImage(named: theme.viewScreenImage), for: UIControlState())
        btnDel.setImage(UIImage(named: theme.viewDelImage), for: UIControlState())
        for button in buttonNumbers {
            button.setBackgroundImage(UIImage(color: theme.viewNumberColor), for: UIControlState())
            button.setBackgroundImage(UIImage(color: theme.viewNumberHiglightColor), for: .highlighted)
        }
        for line in lines {
            line.backgroundColor = theme.viewLineColor
        }
        //监听TextField的text
        _ = self.textField?.reactive.continuousTextValues.observeValues { text in
            self.text = text ?? ""
        }
        for button in buttonNumbers {
            button.isExclusiveTouch = true
            bindNumberButtonAction(button)
        }
        btnKey.isExclusiveTouch = true
        btnOk.isExclusiveTouch = true
        btnDel.isExclusiveTouch = true
        btnDot.isExclusiveTouch = true
        bindKeyButtonAction(btnKey)
        bindKeyButtonAction(btnOk)
        bindDelButtonAction(btnDel)
        bindDotButtonAction(btnDot)
        if self.type == .noDot {
            self.btnDot.isHidden = true
        }
    }
    //小数点输入
    fileprivate func bindDotButtonAction(_ button: UIButton) {
        button.reactive.controlEvents(.touchUpInside).observeValues { [unowned self] _ in
            if self.text.contains(".") {
                return
            }
            //获取光标位置
            let range = self.selectedRange()
            if let tempDelegete = self.textField?.delegate {
                if tempDelegete.responds(to: #selector(UITextFieldDelegate.textField)) {
                    if !tempDelegete.textField!(self.textField!, shouldChangeCharactersIn:range ,replacementString: "."){
                        return
                    }
                }
            }
            let forward = self.getForwardString(self.text, range: range)
            let behind = self.getBehindString(self.text, range: range)
            let (text, newRange) = self.matchInputDot(self.text, new: forward + "." + behind)
            self.textField?.text = text
            self.setSelectedRange(newRange)
        }
    }
    //删除事件
    fileprivate func bindDelButtonAction(_ button: UIButton) {
        button.reactive.controlEvents(.touchUpInside).observeValues { [unowned self] _ in
            //获取光标位置
            var range = self.selectedRange()
            if let tempDelegete = self.textField?.delegate {
                if tempDelegete.responds(to: #selector(UITextFieldDelegate.textField)) {
                    if !tempDelegete.textField!(self.textField!, shouldChangeCharactersIn: range, replacementString: "") {
                        return
                    }
                }
            }
            if range.location == 0 {
                return
            }
            //删除
            range.location -= 1
            let forward = self.getForwardString(self.text, range: range)
            let behind = self.getBehindString(self.text, range: NSMakeRange(range.location + 1, range.length))
            let (text, newRange) = self.matchInputDel(self.text, new: forward + behind)
            self.textField?.text = text
            self.setSelectedRange(newRange)
        }
    }
    //数字输入
    fileprivate func bindNumberButtonAction(_ button: UIButton) {
        button.reactive.controlEvents(.touchUpInside).observeValues { _ in
            if let inputText = button.currentTitle {
                if inputText.length <= 0 {
                    return
                }
                //获取光标位置
                let range = self.selectedRange()
                if let tempDelegete = self.textField?.delegate {
                    if tempDelegete.responds(to: #selector(UITextFieldDelegate.textField)) {
                        if !tempDelegete.textField!(self.textField!, shouldChangeCharactersIn: range, replacementString: inputText) {
                            return
                        }
                    }
                }
                let forward = self.getForwardString(self.text, range: range)
                let behind = self.getBehindString(self.text, range: range)
                let (text, newRange) = self.matchInputNumber(self.text, new: forward + inputText + behind)
                self.textField?.text = text
                self.setSelectedRange(newRange)
            }
        }
    }
    //键盘回收
    fileprivate func bindKeyButtonAction(_ button: UIButton) {
        button.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
            if let temp = self?.text {
                self?.textField?.text = self?.matchConfirm(temp)
            }
            self?.textField?.resignFirstResponder()
        }
    }
    //删除
    fileprivate func matchInputDel(_ old : String, new : String) -> (String, NSRange) {
        //删除小数点匹配
        if old.contains(".") && !new.contains(".") {
            return matchDeleteDot(old, new: new)
        } else {
            return matchDeleteNumber(old, new: new)
        }
    }
    //确定---匹配
    open func matchConfirm(_ input : String) -> String {
        if input == "" {
            return ""
        }
        let noSpacesStr = input.replacingOccurrences(of: " ", with: "")
        let output =  NSDecimalNumber(string : noSpacesStr)
        return "\(output)"
//        var output = input
//        if let number = input.toFloat() {
//            output = String(format: "%.2f", number)
//            if output.toNSString.substringFromIndex(output.length - 3) == ".00" {
//                output = output.toNSString.substringToIndex(output.length - 3)
//            } else if output.toNSString.substringFromIndex(output.length - 1) == "0" {
//                output = output.toNSString.substringToIndex(output.length - 1)
//            }
//        }
//        return output
    }
    //输入小数点---匹配
    open func matchInputDot(_ old : String, new : String) -> (String, NSRange) {
        //获取光标位置
        var range = self.selectedRange()
        var result = old
        if matchNumber(new) {
            range.location += 1
            result = new
        } else {
            if old.contains(".") {
                result = old
            } else {
                if new.toNSString.substring(to: 1) == "." {
                    range.location += 2
                    result = "0" + new
                } else {
                    range.location += 1
                    result = new
                }
            }
        }
        //金额类型的特殊处理
        if self.limitWithTwoPoint(result) {
            let dotArray = result.components(separatedBy: ".")
            if let forward = dotArray.first {
                if var behind = dotArray.last {
                    behind = behind.toNSString.substring(to: 2)
                    result = forward + "." + behind
                }
            }
        }
        return (result, range)
    }
    //删除小数点---匹配
    open func matchDeleteDot(_ old : String, new : String) -> (String, NSRange) {
        //获取光标位置
        var range = self.selectedRange()
        var result = old
        if matchNumber(new) {
            if new.toNSString.substring(to: 1) == "0" && new != "0" {
                if let returnString = new.toInt() {
                    range.location = 0
                    result = String(format: "%d",returnString)
                } else {
                    result = old
                }
            } else {
                range.location -= 1
                result = new
            }
        } else {
            range.location -= 1
            result = new
        }
        return (result, range)
    }
    //输入数字---匹配
    open func matchInputNumber(_ old : String, new : String) -> (String, NSRange) {
        //获取光标位置
        var range = self.selectedRange()
        var result = old
        let oldArray = old.components(separatedBy: ".")
        let newArray = new.components(separatedBy: ".")
        if oldArray.last == newArray.last {
            range.location += 1
            result = new
            return (result, range)
        }
        //判断是否需要处理限制两位小数逻辑
        if !self.limitWithTwoPoint(old) {
            range.location += 1
            result = new
        }
        return (result, range)
    }
    //删除数字---匹配
    open func matchDeleteNumber(_ old : String, new : String) -> (String, NSRange) {
        //获取光标位置
        var range = self.selectedRange()
        range.location -= 1
        return (new, range)
    }
    //数字正则匹配
    fileprivate func matchNumber(_ string : String) -> Bool {
        //(string =~ "^[0-9]+[.][0-9]+$") || string =~ "^[0-9]+$"
        return string =~ "^\\d+\\.?\\d*$"
    }
    /**
     *  光标选择的范围
     *
     *  @return 获取光标选择的范围
     */
    fileprivate func selectedRange() -> NSRange {
        if let tempTextField = self.textField {            //开始位置
            let beginning = tempTextField.beginningOfDocument;
            //光标选择区域
            if let selectedRange = tempTextField.selectedTextRange {
                //选择的开始位置
                let selectionStart = selectedRange.start;
                //选择的结束位置
                let selectionEnd = selectedRange.end;
                //选择的实际位置
                let location = tempTextField.offset(from: beginning, to: selectionStart)
                //选择的长度
                let length = tempTextField.offset(from: selectionStart, to: selectionEnd)
                return NSMakeRange(location, length);
            }
        }
        return NSMakeRange(0, 0)
    }
    /**
     *  设置光标选择的范围
     *
     *  @param range 光标选择的范围
     */
    fileprivate func setSelectedRange(_ range : NSRange) {
        if let tempTextField = self.textField {
            let beginning = tempTextField.beginningOfDocument;
            let startPosition = tempTextField.position(from: beginning, offset: range.location) ?? UITextPosition()
            let endPosition = tempTextField.position(from: beginning, offset: range.location + range.length) ??  UITextPosition()
            let selectionRange = tempTextField.textRange(from: startPosition, to: endPosition)
            tempTextField.selectedTextRange = selectionRange
            self.textField?.sendActions(for: .editingChanged)
        }
    }
    //获取光标前的字符串
    fileprivate func getForwardString(_ string : String, range : NSRange) -> String {
        if self.text.length > range.location {
            return self.text.toNSString.substring(with: NSMakeRange(0, range.location))
        }
        return self.text
    }
    //获取光标后的字符串
    fileprivate func getBehindString(_ string : String, range : NSRange) -> String {
        let length = string.length
        let rangeLength = length > range.location ? length - range.location : 0
        if range.location >= length {
            return "" //防止越界
        }
        return self.text.toNSString.substring(with: NSMakeRange(range.location, rangeLength))
    }
    //限制两位小数逻辑处理
    fileprivate func limitWithTwoPoint(_ string : String) -> Bool {
        if self.type == .money && string.contains(".") {
            let dotArray = string.components(separatedBy: ".")
            if let behind = dotArray.last {
                if behind.length >= 2 {
                    return true
                }
            }
        }
        return false
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
