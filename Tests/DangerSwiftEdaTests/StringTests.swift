//
//  StringTests.swift
//  
//
//  Created by 史 翔新 on 2021/11/11.
//

import XCTest
@testable import DangerSwiftEda

final class StringTests: XCTestCase {
    
    func test_substring() {
        
        typealias TestCase = (input: String, regex: String, expected: String?)
        let testCases: [TestCase] = [
            ("issue/123", #"issue/(\d+)"#, "123"),
            ("ticket/123", #"issue/(\d+)"#, nil),
            ("ticket/ABC-123", #"ticket/(.+)"#, "ABC-123"),
        ]
        
        for testCase in testCases {
            let result = testCase.input.substring(ofPattern: testCase.regex)
            XCTAssertEqual(result, testCase.expected)
        }
        
    }
    
}
