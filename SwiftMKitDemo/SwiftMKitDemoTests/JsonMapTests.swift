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
@testable import SwiftMKitDemo

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
    
    var studentJSON = ["id":1,"name":"张三","age":20,"money":100.21,"height":183.10,
                       "teacher":["id":1,"name":"李老师"]] as [String : Any]
    var teacherJSON = ["id":1,"name":"李老师",
                       "students":[
                        ["id":1,"name":"张三","age":20,"money":100.21,"height":183.10,
                            "teacher":["id":1,"name":"李老师"]],
                        ["id":2,"name":"李四","age":21,"money":101.21,"height":182.10,
                            "teacher":["id":1,"name":"李老师"]]]] as [String : Any]
    var studentJSONUpdated = ["id":1,"name":"张三","age":20,"money":110.21,"height":183.10,
                              "teacher":["id":2,"name":"王老师"]] as [String : Any]
    var teacherJSONNew = ["id":2,"name":"李李老师",
                          "students":[
                            ["id":1,"name":"张三","age":20,"money":100.21,"height":183.10,
                                "teacher":["id":2]],
                            ["id":2,"name":"李四","age":21,"money":101.21,"height":182.10,
                                "teacher":["id":2]]]] as [String : Any]

    func validateStudent(_ student: TestStudent?) {
        XCTAssertNotNil(student)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age)
        XCTAssertEqual("100.21", student!.money?.stringValue)
        XCTAssertEqual(183.1, student!.height)
        XCTAssertNotNil(student?.teacher)
        XCTAssertEqual("李老师", student!.teacher?.name)
    }
    func validateStudents(_ students: [TestStudent]?) {
        XCTAssertEqual(2, students?.count)
        let student:TestStudent? = students![0]
        XCTAssertNotNil(student)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age)
        XCTAssertEqual("100.21", student!.money?.stringValue)
        XCTAssertEqual(183.1, student!.height)
    }
    func validateTeacher(_ teacher: TestTeacher?) {
        XCTAssertNotNil(teacher)
        XCTAssertEqual("李老师", teacher!.name)
        XCTAssertNotNil(teacher?.students)
        XCTAssertEqual(2, teacher?.students?.count)
        let studentInTeacher:TestStudent? = teacher?.students?.first
        XCTAssertEqual("张三", studentInTeacher!.name)
        XCTAssertEqual(20, studentInTeacher!.age)
        XCTAssertEqual(183.1, studentInTeacher!.height)
        XCTAssertEqual(100.21, studentInTeacher!.money)
    }
    
    func validateStudentEntity(_ student: TestStudentEntity?, updated: Bool = false) {
        XCTAssertNotNil(student)
        XCTAssertEqual("1", student!.entityId)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age)
        XCTAssertEqual(183.1, student!.height)
        XCTAssertNotNil(student?.teacher)
        if updated {
            XCTAssertEqual(110.21, student!.money)
            XCTAssertEqual("2", student!.teacher?.entityId)
            XCTAssertEqual("王老师", student!.teacher?.name)
        } else {
            XCTAssertEqual(100.21, student!.money)
            XCTAssertEqual("1", student!.teacher?.entityId)
            XCTAssertEqual("李老师", student!.teacher?.name)
        }
    }
    func validateStudentsEntity(_ students: [TestStudentEntity]?) {
        XCTAssertEqual(2, students?.count)
        let student:TestStudentEntity? = students![0]
        let student2:TestStudentEntity? = students![1]
        XCTAssertNotNil(student)
        XCTAssertEqual("张三", student!.name)
        XCTAssertEqual(student!.name, student!.aliasName)
        XCTAssertEqual(20, student!.age)
        XCTAssertEqual(100.21, student!.money)
        XCTAssertEqual(183.1, student!.height)
        XCTAssertGreaterThanOrEqual(Int64(student2!.entityUpdateTime), Int64(student!.entityUpdateTime))
        XCTAssertGreaterThan(student2!.entityOrder, student!.entityOrder)
    }
    func validateTeacherEntity(_ teacher: TestTeacherEntity?, updated: Bool = false) {
        XCTAssertNotNil(teacher)
        XCTAssertEqual("李老师", teacher!.name)
        XCTAssertNotNil(teacher?.students)
        if updated {
            XCTAssertEqual(1, teacher?.students?.count)
            let set:NSOrderedSet = (teacher?.students)!
            let studentInTeacher:TestStudentEntity? = set.objectAtIndex(0) as? TestStudentEntity
            XCTAssertEqual("李四", studentInTeacher!.name)
            XCTAssertEqual(21, studentInTeacher!.age)
            XCTAssertEqual(182.1, studentInTeacher!.height)
            XCTAssertEqual(101.21, studentInTeacher!.money)
        } else {
            XCTAssertEqual(2, teacher?.students?.count)
            let set:NSOrderedSet = (teacher?.students)!
            let studentInTeacher:TestStudentEntity? = set.objectAtIndex(0) as? TestStudentEntity
            XCTAssertEqual("张三", studentInTeacher!.name)
            XCTAssertEqual(20, studentInTeacher!.age)
            XCTAssertEqual(183.1, studentInTeacher!.height)
            XCTAssertEqual(100.21, studentInTeacher!.money)
        }
    }
    func validateTeacherEntityNew(_ teacher: TestTeacherEntity?) {
        XCTAssertNotNil(teacher)
        XCTAssertEqual("李李老师", teacher!.name)
        XCTAssertNotNil(teacher?.students)
        XCTAssertEqual(2, teacher?.students?.count)
    }
    
    
//    func testMJExtension() {
//        let student:TestStudent? = TestStudent.objectFromJson(studentJSON)
//        let teacher:TestTeacher? = TestTeacher.objectFromJson(teacherJSON)
//        let students:[TestStudent]? = TestStudent.arrayFromJson(teacherJSON["students"] as? Array<AnyObject>)
//        validateStudent(student)
//        validateTeacher(teacher)
//        validateStudents(students)
//        let studentEntity:TestStudentEntity? = TestStudentEntity.objectFromJson(studentJSON, context: NSManagedObjectContext.MR_defaultContext())
//        let teacherEntity:TestTeacherEntity? = TestTeacherEntity.objectFromJson(teacherJSON, context: NSManagedObjectContext.MR_defaultContext())
//        let studentsEntity:[TestStudentEntity]? = TestStudentEntity.arrayFromJson(teacherJSON["students"] as? Array<AnyObject>, context: NSManagedObjectContext.MR_defaultContext())
//        let studentInTeacher:TestStudentEntity? = teacherEntity?.students!.objectAtIndex(0) as? TestStudentEntity
//        validateStudentEntity(studentEntity)
//        validateTeacherEntity(teacherEntity)
//        validateStudentsEntity(studentsEntity)
//        XCTAssertEqual(studentEntity, studentInTeacher)
//        var studentEntityUpdated:TestStudentEntity? = TestStudentEntity.objectFromJson(studentJSON, context: NSManagedObjectContext.MR_defaultContext())
//        validateStudentEntity(studentEntityUpdated)
//        XCTAssertEqual(studentEntity, studentEntityUpdated)
//        studentEntityUpdated = TestStudentEntity.objectFromJson(studentJSONUpdated, context: NSManagedObjectContext.MR_defaultContext())
//        validateStudentEntity(studentEntityUpdated, updated: true)
//        validateStudentEntity(studentEntity, updated: true)
//        XCTAssertEqual(studentEntity, studentInTeacher)
//        XCTAssertEqual(studentEntity, studentEntityUpdated)
//        validateTeacherEntity(teacherEntity, updated: true)
//        let teacherEntityUpdated:TestTeacherEntity? = TestTeacherEntity.objectFromJson(teacherJSONNew, context: NSManagedObjectContext.MR_defaultContext())
//        validateTeacherEntityNew(teacherEntityUpdated)
//        validateTeacherEntityNew(studentEntity?.teacher)
//        XCTAssertEqual(0, teacherEntity?.students?.count)
//        XCTAssertEqual(teacherEntityUpdated, studentEntity?.teacher)
//        let studentMR = TestStudentEntity.MR_findAllWithPredicate(NSPredicate(format: "entityId = %@", "1"))?.first
//        XCTAssertEqual(studentMR, studentEntity)
//        
//    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
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
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable: Any]! {
        return ["aliasName": "name"]
    }
}
class TestTeacher: NSObject {
    var name:String?
    var students:[TestStudent]?
    
    override static func mj_objectClassInArray() -> [AnyHashable: Any]! {
        return ["students": "SwiftMKitDemoTests.TestStudent"]
    }
}
extension TestStudentEntity {
    override internal static func mj_replacedKeyFromPropertyName() -> [AnyHashable: Any]! {
        return ["entityId":"id",
                "aliasName": "name"]
    }
}
extension TestTeacherEntity {
    override internal static func mj_replacedKeyFromPropertyName() -> [AnyHashable: Any]! {
        return ["entityId":"id"]
    }
    override internal static func mj_objectClassInArray() -> [AnyHashable: Any]! {
        return ["students": "TestStudentEntity"]
    }
}
