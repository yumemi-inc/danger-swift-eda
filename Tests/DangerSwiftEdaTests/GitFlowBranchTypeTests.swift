//
//  GitFlowBranchTypeTests.swift
//  
//
//  Created by 史 翔新 on 2021/11/11.
//

import XCTest
@testable import DangerSwiftEda

final class GitFlowBranchTypeTests: XCTestCase {
    
    func test_parsed() {
        
        typealias TestCase = (line: UInt, input: String, expected: GitFlow.Branch?)
        let testCases: [TestCase] = [
            
            (#line, "main",                    .main),
            (#line, "main/xyz",                nil),
            (#line, "main/issue/123",          nil),
            (#line, "main/ticket/ABC-123",     nil),
            
            (#line, "develop",                 .develop),
            (#line, "develop/xyz",             nil),
            (#line, "develop/issue/123",       nil),
            (#line, "develop/ticket/ABC-123",  nil),
            
            (#line, "hotfix",                  nil),
            (#line, "hotfix/xyz",              .hotfix(nil)),
            (#line, "hotfix/issue/123",        .hotfix(.issue("123"))),
            (#line, "hotfix/ticket/ABC-123",   .hotfix(.ticket("ABC-123"))),
            
            (#line, "feature",                 nil),
            (#line, "feature/xyz",             .feature(nil)),
            (#line, "feature/issue/123",       .feature(.issue("123"))),
            (#line, "feature/ticket/ABC-123",  .feature(.ticket("ABC-123"))),
            
            (#line, "release",                 nil),
            (#line, "release/xyz",             .release(nil)),
            (#line, "release/issue/123",       .release(.issue("123"))),
            (#line, "release/ticket/ABC-123",  .release(.ticket("ABC-123"))),
            
            (#line, "ci",                      nil),
            (#line, "ci/xyz",                  .ci),
            (#line, "ci/issue/123",            .ci),
            (#line, "ci/ticket/ABC-123",       .ci),
            
        ]
        
        for testCase in testCases {
            XCTAssertEqual(GitFlow.Branch.defaultParsingMethod(name: testCase.input), testCase.expected, line: testCase.line)
        }
        
    }
    
}
