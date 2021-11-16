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
            
            ("main",                    .makeMain()),
            ("main/xyz",                nil),
            ("main/issue/123",          nil),
            ("main/ticket/ABC-123",     nil),
            
            ("develop",                 .makeDevelop()),
            ("develop/xyz",             nil),
            ("develop/issue/123",       nil),
            ("develop/ticket/ABC-123",  nil),
            
            ("hotfix",                  nil),
            ("hotfix/xyz",              .makeHotfix(nil)),
            ("hotfix/issue/123",        .makeHotfix(.issue("123"))),
            ("hotfix/ticket/ABC-123",   .makeHotfix(.ticket("ABC-123"))),
            
            ("feature",                 nil),
            ("feature/xyz",             .makeFeature(nil)),
            ("feature/issue/123",       .makeFeature(.issue("123"))),
            ("feature/ticket/ABC-123",  .makeFeature(.ticket("ABC-123"))),
            
            ("release",                 nil),
            ("release/xyz",             .makeRelease(nil)),
            ("release/issue/123",       .makeRelease(.issue("123"))),
            ("release/ticket/ABC-123",  .makeRelease(.ticket("ABC-123"))),
            
            ("ci",                      nil),
            ("ci/xyz",                  .makeCI()),
            ("ci/issue/123",            .makeCI()),
            ("ci/ticket/ABC-123",       .makeCI()),
            
        ]
        
        for testCase in testCases {
            XCTAssertEqual(Branch.parsed(from: testCase.input), testCase.expected)
        }
        
    }
    
}
