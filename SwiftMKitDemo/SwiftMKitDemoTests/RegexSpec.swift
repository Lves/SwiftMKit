//
//  RegexSpec.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/12/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import SwiftMKitDemo

class RegexSpec: QuickSpec {

    
    override func spec() {
        describe("Regex test") {
            context("regex is work") {
                let match = ("onev@onevcat.com" =~ "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$")
                
                it("email regex should match") {
                    expect(match).to(equal(true))
                }
            }
        }
    }

}
