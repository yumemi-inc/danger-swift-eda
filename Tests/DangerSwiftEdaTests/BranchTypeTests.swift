//
//  BranchTypeTests.swift
//  
//
//  Created by 史 翔新 on 2021/11/11.
//

import XCTest
@testable import DangerSwiftEda

final class BranchTypeTests: XCTestCase {
    
    func test_parsed() {
        
        typealias TestCase = (input: String, expected: Branch?)
        let testCases: [TestCase] = [
            
            ("main",                    .main),
            ("main/xyz",                nil),
            ("main/issue/123",          nil),
            ("main/ticket/ABC-123",     nil),
            
            ("develop",                 .develop),
            ("develop/xyz",             nil),
            ("develop/issue/123",       nil),
            ("develop/ticket/ABC-123",  nil),
            
            ("hotfix",                  nil),
            ("hotfix/xyz",              .hotfix(nil)),
            ("hotfix/issue/123",        .hotfix(.issue("123"))),
            ("hotfix/ticket/ABC-123",   .hotfix(.ticket("ABC-123"))),
            
            ("feature",                 nil),
            ("feature/xyz",             .feature(nil)),
            ("feature/issue/123",       .feature(.issue("123"))),
            ("feature/ticket/ABC-123",  .feature(.ticket("ABC-123"))),
            
            ("release",                 nil),
            ("release/xyz",             .release(nil)),
            ("release/issue/123",       .release(.issue("123"))),
            ("release/ticket/ABC-123",  .release(.ticket("ABC-123"))),
            
            ("ci",                      nil),
            ("ci/xyz",                  .ci),
            ("ci/issue/123",            .ci),
            ("ci/ticket/ABC-123",       .ci),
            
        ]
        
        for testCase in testCases {
            XCTAssertEqual(Branch.parsed(from: testCase.input), testCase.expected)
        }
        
    }
    
}
