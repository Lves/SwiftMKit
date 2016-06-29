//
//  NumberKeyboard.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CocoaLumberjack
import IQKeyboardManager

struct NumberKeyboardUITheme {
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

public class NumberKeyboard: UIView, NumberKeyboardProtocol {
    
    struct Theme {
        static let DefaultTheme: NumberKeyboardUITheme = NumberKeyboardUITheme(
            viewBackgroundColor: UIColor(hex6: 0x8C8C8C),
            viewLineColor: UIColor(hex6: 0x8C8C8C),
            viewEnterColor: UIColor(hex6: 0xFD734C),
            viewDelColor: UIColor(hex6: 0xFFFFFF),
            viewNumberColor: UIColor(hex6: 0xFFFFFF),
            viewEnterHiglightColor: UIColor(hex6: 0xFD734C),
            viewDelHiglightColor: UIColor(hex6: 0xC0C7D4),
            viewNumberHiglightColor: UIColor(hex6: 0xC0C7D4),
            viewDelImage: "keyboard_view_del",
            viewScreenImage: "keyboard_view_screen")
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
    
    public var type: NumberKeyboardType = .Normal
    public var textField: UITextField?
    public var text: String = ""
    public var enableAutoToolbar = true {
        willSet {
            IQKeyboardManager.sharedManager().enableAutoToolbar = newValue
        }
    }
    
    public static func keyboard(textField: UITextField, type: NumberKeyboardType = .Normal) -> NumberKeyboard {
        return keyboard(textField, type: type, style: .Default)
    }
    public static func keyboard(textField: UITextField, type: NumberKeyboardType = .Normal, style: NumberKeyboardStyle) -> NumberKeyboard {
        let view = NSBundle.mainBundle().loadNibNamed("NumberKeyboard", owner: self, options: nil).first as? NumberKeyboard
        view?.textField = textField
        view?.type = type
        view?.setupUI(style)
        return view!
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func clear() {
        text = ""
    }
    
    private func setupUI(style: NumberKeyboardStyle) {
        var theme = Theme.DefaultTheme
        switch style {
        case .Default:
            theme = Theme.DefaultTheme
        }
        btnDel.setBackgroundImage(UIImage(color: theme.viewDelColor), forState: .Normal)
        btnOk.setBackgroundImage(UIImage(color: theme.viewEnterColor), forState: .Normal)
        btnKey.setBackgroundImage(UIImage(color: theme.viewNumberColor), forState: .Normal)
        btnDel.setBackgroundImage(UIImage(color: theme.viewDelHiglightColor), forState: .Highlighted)
        btnOk.setBackgroundImage(UIImage(color: theme.viewEnterHiglightColor), forState: .Highlighted)
        btnKey.setBackgroundImage(UIImage(color: theme.viewNumberHiglightColor), forState: .Highlighted)
        btnKey.setImage(UIImage(named: theme.viewScreenImage), forState: .Normal)
        btnDel.setImage(UIImage(named: theme.viewDelImage), forState: .Normal)
        for button in buttonNumbers {
            button.setBackgroundImage(UIImage(color: theme.viewNumberColor), forState: .Normal)
            button.setBackgroundImage(UIImage(color: theme.viewNumberHiglightColor), forState: .Highlighted)
        }
        for line in lines {
            line.backgroundColor = theme.viewLineColor
        }
        //监听TextField的text
        self.textField?.rac_textSignalProducer().startWithNext { text in
            self.text = text
        }
        for button in buttonNumbers {
            button.exclusiveTouch = true
            bindNumberButtonAction(button)
        }
        btnKey.exclusiveTouch = true
        btnOk.exclusiveTouch = true
        btnDel.exclusiveTouch = true
        btnDot.exclusiveTouch = true
        bindKeyButtonAction(btnKey)
        bindKeyButtonAction(btnOk)
        bindDelButtonAction(btnDel)
        bindDotButtonAction(btnDot)
        if self.type == .NoDot {
            self.btnDot.hidden = true
        }
    }
    //小数点输入
    private func bindDotButtonAction(button: UIButton) {
        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { _ in
            if self.text.contains(".") {
                return
            }
            //获取光标位置
            let range = self.selectedRange()
            if let tempDeleget = self.textField?.delegate {
                if tempDeleget.respondsToSelector(#selector(UITextFieldDelegate.textField(_:shouldChangeCharactersInRange:replacementString:))) {
                    if !tempDeleget.textField!(self.textField!, shouldChangeCharactersInRange: range, replacementString: ".") {
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
    private func bindDelButtonAction(button: UIButton) {
        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
            //获取光标位置
            var range = self.selectedRange()
            if let tempDeleget = self.textField?.delegate {
                if tempDeleget.respondsToSelector(#selector(UITextFieldDelegate.textField(_:shouldChangeCharactersInRange:replacementString:))) {
                    if !tempDeleget.textField!(self.textField!, shouldChangeCharactersInRange: range, replacementString: "") {
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
    private func bindNumberButtonAction(button: UIButton) {
        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { _ in
            if let inputText = button.currentTitle {
                if inputText.length <= 0 {
                    return
                }
                //获取光标位置
                let range = self.selectedRange()
                if let tempDeleget = self.textField?.delegate {
                    if tempDeleget.respondsToSelector(#selector(UITextFieldDelegate.textField(_:shouldChangeCharactersInRange:replacementString:))) {
                        if !tempDeleget.textField!(self.textField!, shouldChangeCharactersInRange: range, replacementString: inputText) {
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
    private func bindKeyButtonAction(button: UIButton) {
        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [weak self] _ in
            self?.textField?.resignFirstResponder()
            if let temp = self?.text {
                self?.textField?.text = self?.matchConfirm(temp)
            }
        }
    }
    //删除
    private func matchInputDel(old : String, new : String) -> (String, NSRange) {
        //删除小数点匹配
        if old.contains(".") && !new.contains(".") {
            return matchDeleteDot(old, new: new)
        } else {
            return matchDeleteNumber(old, new: new)
        }
    }
    //确定---匹配
    public func matchConfirm(input : String) -> String {
        if input == "" {
            return ""
        }
        let output =  NSDecimalNumber(string : input)
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
    public func matchInputDot(old : String, new : String) -> (String, NSRange) {
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
                if new.toNSString.substringToIndex(1) == "." {
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
            let dotArray = result.componentsSeparatedByString(".")
            if let forward = dotArray.first {
                if var behind = dotArray.last {
                    behind = behind.toNSString.substringToIndex(2)
                    result = forward + "." + behind
                }
            }
        }
        return (result, range)
    }
    //删除小数点---匹配
    public func matchDeleteDot(old : String, new : String) -> (String, NSRange) {
        //获取光标位置
        var range = self.selectedRange()
        var result = old
        if matchNumber(new) {
            if new.toNSString.substringToIndex(1) == "0" && new != "0" {
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
    public func matchInputNumber(old : String, new : String) -> (String, NSRange) {
        //获取光标位置
        var range = self.selectedRange()
        var result = old
        //判断是否需要处理限制两位小数逻辑
        if !self.limitWithTwoPoint(old) {
            range.location += 1
            result = new
        }
        return (result, range)
    }
    //删除数字---匹配
    public func matchDeleteNumber(old : String, new : String) -> (String, NSRange) {
        //获取光标位置
        var range = self.selectedRange()
        range.location -= 1
        return (new, range)
    }
    //数字正则匹配
    private func matchNumber(string : String) -> Bool {
        //(string =~ "^[0-9]+[.][0-9]+$") || string =~ "^[0-9]+$"
        return string =~ "^\\d+\\.?\\d*$"
    }
    /**
     *  光标选择的范围
     *
     *  @return 获取光标选择的范围
     */
    private func selectedRange() -> NSRange {
        if let tempTextField = self.textField {            //开始位置
            let beginning = tempTextField.beginningOfDocument;
            //光标选择区域
            if let selectedRange = tempTextField.selectedTextRange {
                //选择的开始位置
                let selectionStart = selectedRange.start;
                //选择的结束位置
                let selectionEnd = selectedRange.end;
                //选择的实际位置
                let location = tempTextField.offsetFromPosition(beginning, toPosition: selectionStart)
                //选择的长度
                let length = tempTextField.offsetFromPosition(selectionStart, toPosition: selectionEnd)
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
    private func setSelectedRange(range : NSRange) {
        if let tempTextField = self.textField {
            let beginning = tempTextField.beginningOfDocument;
            let startPosition = tempTextField.positionFromPosition(beginning, offset: range.location) ?? UITextPosition()
            let endPosition = tempTextField.positionFromPosition(beginning, offset: range.location + range.length) ??  UITextPosition()
            let selectionRange = tempTextField.textRangeFromPosition(startPosition, toPosition: endPosition)
            tempTextField.selectedTextRange = selectionRange
            self.textField?.sendActionsForControlEvents(.EditingChanged)
        }
    }
    //获取光标前的字符串
    private func getForwardString(string : String, range : NSRange) -> String {
        return self.text.toNSString.substringWithRange(NSMakeRange(0, range.location))
    }
    //获取光标后的字符串
    private func getBehindString(string : String, range : NSRange) -> String {
        let length = string.length
        return self.text.toNSString.substringWithRange(NSMakeRange(range.location, length - range.location))
    }
    //限制两位小数逻辑处理
    private func limitWithTwoPoint(string : String) -> Bool {
        if self.type == .Money && string.contains(".") {
            let dotArray = string.componentsSeparatedByString(".")
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
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
