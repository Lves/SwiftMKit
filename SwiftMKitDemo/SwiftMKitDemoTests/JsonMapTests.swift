//
//  JsonMapTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/25/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import MJExtension

class JsonMapTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    var studentJSON = "{\"name\":\"张三\",\"age\":20,\"money\":100.21,\"height\":183.00,\"teacher\":{\"name\":\"李老师\",\"students\":[{\"name\":\"张三\",\"age\":20,\"money\":100.21,\"height\":183.00}]}}"
    var teacherJSON = "{\"name\":\"李老师\",\"students\":[{\"name\":\"张三\",\"age\":20,\"money\":100.21,\"height\":183.00}]}"

    func validateStudent(student: TestStudent?) {
        XCTAssertNotNil(student)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age?.integerValue)
        XCTAssertEqual("100.21", student!.money?.stringValue)
        XCTAssertEqual(183.0, student!.height?.doubleValue)
        XCTAssertNotNil(student?.teacher)
        XCTAssertEqual("李老师", student!.teacher?.name)
        XCTAssertNotNil(student?.teacher?.students)
        XCTAssertEqual(1, student?.teacher?.students?.count)
    }
    func validateTeacher(teacher: TestTeacher?) {
        XCTAssertNotNil(teacher)
        XCTAssertEqual("李老师", teacher!.name)
        XCTAssertNotNil(teacher?.students)
        XCTAssertEqual(1, teacher?.students?.count)
        let studentInTeacher:TestStudent? = teacher?.students?.firstObject as? TestStudent
        XCTAssertEqual("张三", studentInTeacher!.name)
        XCTAssertEqual(20, studentInTeacher!.age)
        XCTAssertEqual("100.21", studentInTeacher!.money?.stringValue)
        XCTAssertEqual(183.0, studentInTeacher!.height)
    }
    
    func testMJExtension() {
        let student:TestStudent? = TestStudent.objectFromJson(studentJSON)
        let teacher:TestTeacher? = TestTeacher.objectFromJson(teacherJSON)
        validateStudent(student)
        validateTeacher(teacher)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}

class TestStudent : NSObject {
    var name:String?
    var aliasName:String?
    var age:NSNumber?
    var money:NSNumber?
    var height:NSNumber?
    var teacher:TestTeacher?
    
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["aliasName": "name"]
    }
}
class TestTeacher: NSObject {
    var name:String?
    var students: NSArray?
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["students": "TestStudent"]
    }
}