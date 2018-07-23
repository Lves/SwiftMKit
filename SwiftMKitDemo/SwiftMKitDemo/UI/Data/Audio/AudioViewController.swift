//
//  AudioViewController.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/7/13.
//  Copyright © 2018年 cdts. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class AudioViewController: UIViewController, AKKeyboardDelegate {

    let bank = AKOscillatorBank()
    var keyboardView: AKKeyboardView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioKit.output = bank
        try? AudioKit.start()
        
        keyboardView = AKKeyboardView(width: 440, height: 100)

        keyboardView?.delegate = self
//        keyboard.polyphonicMode = true
        self.view.addSubview(keyboardView!)
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        keyboardView?.frame = CGRect(x: 0, y: 100, w: 440, h: 100)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func noteOn(note: MIDINoteNumber) {
        bank.play(noteNumber: note, velocity: 80)
    }
    
    func noteOff(note: MIDINoteNumber) {
        bank.stop(noteNumber: note)
    }
}
