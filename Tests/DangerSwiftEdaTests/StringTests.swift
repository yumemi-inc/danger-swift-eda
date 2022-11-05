//
//  StringTests.swift
//  
//
//  Created by 史 翔新 on 2021/11/11.
//

import XCTest
@testable import DangerSwiftEda

final class StringTests: XCTestCase {
    
    func test_matches() {
        
        typealias TestCase<R: RegexComponent> = (line: UInt, input: String, regex: R, expected: Bool)
        let testCases: [TestCase] = [
            (#line, "issue/123", #/issue/(\d+)/#, true),
            (#line, "ticket/123", #/issue/(\d+)/#, false),
            (#line, "ticket/ABC-123", #/ticket/(.+)/#, true),
        ]
        
        for testCase in testCases {
            let result = testCase.input.matches(testCase.regex)
            XCTAssertEqual(result, testCase.expected, line: testCase.line)
        }
        
    }
    
}
