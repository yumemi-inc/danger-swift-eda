//
//  StringContainer.swift
//  
//
//  Created by 史 翔新 on 2021/12/07.
//

import XCTest
@testable import DangerSwiftHammer
@testable import DangerSwiftShoki

extension XCTestCase {
    
    final class StringContainer {
        
        var string: String
        
        init(string: String = "") {
            self.string = string
        }
        
    }
    
    func XCTAssert(hammer: Hammer, container: StringContainer, line: UInt = #line) {
        
        container.string = "initial"
        precondition(container.string == "initial")
        
        XCTAssertEqual(hammer.shellCommandExecutor("new"), "executed", line: line)
        XCTAssertEqual(container.string, "new")
        
    }
    
    func XCTAssert(shoki: Shoki, container: StringContainer, line: UInt = #line) {
        
        container.string = "initial"
        precondition(container.string == "initial")
        
        shoki.message("new")
        XCTAssertEqual(container.string, "new", line: line)
        
    }
    
    func XCTAssert(stringExecution: (String) -> Void, container: StringContainer, line: UInt = #line) {
        
        container.string = "initial"
        precondition(container.string == "initial")
        
        stringExecution("new")
        XCTAssertEqual(container.string, "new", line: line)
        
    }
    
}
