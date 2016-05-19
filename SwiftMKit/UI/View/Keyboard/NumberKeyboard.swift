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

public enum NumberKeyboardType: Int {
    case Normal, NoDot, Money
}

public protocol NumberKeyboardProtocol {
    var type: NumberKeyboardType { get set }
    var text: String { get set }
    var textField: UITextField? { get }
    func clear()
}


public class NumberKeyboard: UIView, NumberKeyboardProtocol {

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
    
    var buttonNumbers: [UIButton] {
        get {
            return [btn0,btn1,btn2,btn3,btn4,btn5,btn6,btn7,btn8,btn9]
        }
    }
    
    public var type: NumberKeyboardType = .Normal
    public var textField: UITextField?
    public var text: String = ""
    
    lazy var inputAction: CocoaAction = {
        let action = Action<AnyObject, AnyObject, NSError> { [weak self] input in
            return SignalProducer { [weak self] (sink, _) in
                
                sink.sendNext(input)
                sink.sendCompleted()
            }
        }
        action.errors.observe { error in
            DDLogError("\(error)")
        }
        return CocoaAction(action, input:"")
    }()
    
    public static func keyboard(textField: UITextField, type:NumberKeyboardType = .Normal) -> UIView? {
        let view = NSBundle.mainBundle().loadNibNamed("NumberKeyboard", owner: self, options: nil).first as? NumberKeyboard
        view?.textField = textField
        view?.type = type
        view?.initUI()
        return view
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
    
    private func initUI() {
        //监听TextField的text
        self.textField?.rac_textSignalProducer().startWithNext { text in
            self.text = text
        }
        for button in buttonNumbers {
            bindNumberButtonAction(button)
        }
        bindKeyButtonAction(self.btnKey)
        bindKeyButtonAction(self.btnOk)
        bindDelButtonAction(self.btnDel)
        bindDotButtonAction(self.btnDot)
    }
    //小数点输入
    private func bindDotButtonAction(button: UIButton) {
        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { _ in
            if self.text.contains(".") {
                return
            }
            //获取光标位置
            var range = self.selectedRange()
            if range.location == 0 {
                //重新设置光标位置
                self.textField?.text = "0." + self.text
                range.location += 2
                self.setSelectedRange(range)
            } else {
                self.textField?.text = self.getForwardString(self.text, range: range) + "." + self.getBehindString(self.text, range: range)
                range.location += 1
                self.setSelectedRange(range)
            }
            //判断是否需要处理限制两位小数逻辑
            if self.limitWithTwoPoint() {
                let dotArray = self.text.componentsSeparatedByString(".")
                if let forward = dotArray.first {
                    if var behind = dotArray.last {
                        behind = behind.toNSString.substringToIndex(2)
                        self.textField?.text = forward + "." + behind
                        self.setSelectedRange(range)
                    }
                }
            }
        }
    }
    //删除事件
    private func bindDelButtonAction(button: UIButton) {
        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
            //获取光标位置
            var range = self.selectedRange()
            if range.location == 0 {
                return
            }
            //设置光标的range
            range.location -= 1
            if let tempDeleget = self.textField?.delegate {
                if !tempDeleget.textField!(self.textField!, shouldChangeCharactersInRange: range, replacementString: "") {
                    return
                }
            }
            //删除
            let forward = self.getForwardString(self.text, range: range)
            let behind = self.getBehindString(self.text, range: NSMakeRange(range.location + 1, range.length))
            self.textField?.text = forward + behind
            self.setSelectedRange(range)
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
                    if !tempDeleget.textField!(self.textField!, shouldChangeCharactersInRange: range, replacementString: inputText) {
                        return
                    }
                }
                //输入第二位时第一位为 0 的情况处理
                if self.text == "0" {
                    self.textField?.text = inputText
                    self.setSelectedRange(NSMakeRange(1, 0))
                } else {
                    //添加
                    let forward = self.getForwardString(self.text, range: range)
                    let behind = self.getBehindString(self.text, range: range)
                    if forward.contains(".") {
                        //判断是否需要处理限制两位小数逻辑
                        if self.limitWithTwoPoint() {
                            return
                        }
                    }
                    self.textField?.text = forward + inputText + behind
                    self.setSelectedRange(NSMakeRange(range.location+1, 0))
                }
            }
        }
    }
    //键盘回收
    private func bindKeyButtonAction(button: UIButton) {
        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [weak self] _ in
            self?.textField?.resignFirstResponder()
        }
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
    private func limitWithTwoPoint() -> Bool {
        if self.type == .Money {
            if self.text.contains(".") {
                let dotArray = self.text.componentsSeparatedByString(".")
                if let behind = dotArray.last {
                    if behind.length >= 2 {
                        return true
                    }
                }
            }
        }
        return false
    }
    //数字匹配
    private func numberMatch(old : String, new : String, input : String) -> String {
        let result = (new =~ "^-?([1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*|0?\\.0+|0)$")    //匹配浮点数
        if result {
            return new
        } else {
            if input == "." {
                if old.contains(".") {
                    return old
                } else {
                     
                }
            } else {
                if let returnString = new.toFloat() {
                    return String(format: "%.2f",returnString)
                }
            }
        }
        return old
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
