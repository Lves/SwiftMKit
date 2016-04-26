//
//  JsonMapTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/25/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import MJExtension
import MagicalRecord

class JsonMapTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        MagicalRecord.cleanUp()
    }
    
    var studentJSON = ["name":"张三","age":20,"money":100.21,"height":183.10,"teacher":["name":"李老师","students":[["name":"张三","age":20,"money":100.21,"height":183.10],["name":"李四","age":21,"money":101.21,"height":182.10]]]]
    var teacherJSON = ["name":"李老师","students":[["name":"张三","age":20,"money":100.21,"height":183.10],["name":"李四","age":21,"money":101.21,"height":182.10]]]

    func validateStudent(student: TestStudent?) {
        XCTAssertNotNil(student)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age)
        XCTAssertEqual("100.21", student!.money?.stringValue)
        XCTAssertEqual(183.1, student!.height)
        XCTAssertNotNil(student?.teacher)
        XCTAssertEqual("李老师", student!.teacher?.name)
        XCTAssertNotNil(student?.teacher?.students)
        XCTAssertEqual(2, student?.teacher?.students?.count)
    }
    func validateStudents(students: [TestStudent]?) {
        XCTAssertEqual(2, students?.count)
        let student:TestStudent? = students![0]
        XCTAssertNotNil(student)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age)
        XCTAssertEqual("100.21", student!.money?.stringValue)
        XCTAssertEqual(183.1, student!.height)
    }
    func validateTeacher(teacher: TestTeacher?) {
        XCTAssertNotNil(teacher)
        XCTAssertEqual("李老师", teacher!.name)
        XCTAssertNotNil(teacher?.students)
        XCTAssertEqual(2, teacher?.students?.count)
        let studentInTeacher:TestStudent? = teacher?.students?.first
        XCTAssertEqual("张三", studentInTeacher!.name)
        XCTAssertEqual(20, studentInTeacher!.age)
        XCTAssertEqual("100.21", studentInTeacher!.money?.stringValue)
        XCTAssertEqual(183.1, studentInTeacher!.height)
    }
    
    func validateStudentEntity(student: TestStudentEntity?) {
        XCTAssertNotNil(student)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age?.integerValue)
        XCTAssertEqual("100.21", student!.money?.stringValue)
        XCTAssertEqual(183.1, student!.height?.doubleValue)
        XCTAssertNotNil(student?.teacher)
        XCTAssertEqual("李老师", student!.teacher?.name)
        XCTAssertNotNil(student?.teacher?.students)
        XCTAssertEqual(2, student?.teacher?.students?.count)
    }
    func validateStudentsEntity(students: [TestStudentEntity]?) {
        XCTAssertEqual(2, students?.count)
        let student:TestStudentEntity? = students![0]
        XCTAssertNotNil(student)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age?.integerValue)
        XCTAssertEqual("100.21", student!.money?.stringValue)
        XCTAssertEqual(183.1, student!.height?.doubleValue)
    }
    func validateTeacherEntity(teacher: TestTeacherEntity?) {
        XCTAssertNotNil(teacher)
        XCTAssertEqual("李老师", teacher!.name)
        XCTAssertNotNil(teacher?.students)
        XCTAssertEqual(2, teacher?.students?.count)
        let set:NSOrderedSet = (teacher?.students)!
        let studentInTeacher:TestStudentEntity? = set.objectAtIndex(0) as? TestStudentEntity
        XCTAssertEqual("张三", studentInTeacher!.name)
        XCTAssertEqual(20, studentInTeacher!.age?.integerValue)
        XCTAssertEqual("100.21", studentInTeacher!.money?.stringValue)
        XCTAssertEqual(183.1, studentInTeacher!.height?.doubleValue)
    }
    
    
    func testMJExtension() {
        let student:TestStudent? = TestStudent.objectFromJson(studentJSON)
        let teacher:TestTeacher? = TestTeacher.objectFromJson(teacherJSON)
        let students:[TestStudent]? = TestStudent.arrayFromJson(teacherJSON["students"] as? Array<AnyObject>)
        validateStudent(student)
        validateTeacher(teacher)
        validateStudents(students)
        let studentEntity:TestStudentEntity? = TestStudentEntity.objectFromJson(studentJSON, context: NSManagedObjectContext.MR_defaultContext())
        let teacherEntity:TestTeacherEntity? = TestTeacherEntity.objectFromJson(teacherJSON, context: NSManagedObjectContext.MR_defaultContext())
        let studentsEntity:[TestStudentEntity]? = TestStudentEntity.arrayFromJson(teacherJSON["students"] as? Array<AnyObject>, context: NSManagedObjectContext.MR_defaultContext())
        validateStudentEntity(studentEntity)
        validateTeacherEntity(teacherEntity)
        validateStudentsEntity(studentsEntity)
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
    var age:Int64 = 0
    var money:NSNumber?
    var height:Double = 0
    var teacher:TestTeacher?
    
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["aliasName": "name"]
    }
}
class TestTeacher: NSObject {
    var name:String?
    var students:[TestStudent]?
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["students": "SwiftMKitDemoTests.TestStudent"]
    }
}
extension TestStudentEntity {
    override public static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["aliasName": "name"]
    }
}
extension TestTeacherEntity {
//    override public static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
//        return ["students": "SwiftMKitDemoTests.TestStudentEntity"]
//    }
}