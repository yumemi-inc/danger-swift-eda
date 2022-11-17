//
//  GitHubFlowBranchTypeTests.swift
//  
//
//  Created by 史 翔新 on 2021/11/11.
//

import XCTest
@testable import DangerSwiftEda

final class GitHubFlowBranchTypeTests: XCTestCase {
    
    func test_parsed() {
        
        typealias TestCase = (line: UInt, input: String, expected: GitHubFlow.Branch?)
        let testCases: [TestCase] = [
            
            (#line, "main",                    .main),
            
            (#line, "develop",                 .working),
            (#line, "develop/xyz",             .working),
            (#line, "develop/issue/123",       .working),
            (#line, "develop/ticket/ABC-123",  .working),
            
            (#line, "hotfix",                  .working),
            (#line, "hotfix/xyz",              .working),
            (#line, "hotfix/issue/123",        .working),
            (#line, "hotfix/ticket/ABC-123",   .working),
            
            (#line, "feature",                 .working),
            (#line, "feature/xyz",             .working),
            (#line, "feature/issue/123",       .working),
            (#line, "feature/ticket/ABC-123",  .working),
            
            (#line, "release",                 .working),
            (#line, "release/xyz",             .working),
            (#line, "release/issue/123",       .working),
            (#line, "release/ticket/ABC-123",  .working),
            
            (#line, "ci",                      .ci),
            (#line, "ci/xyz",                  .ci),
            (#line, "ci/issue/123",            .ci),
            (#line, "ci/ticket/ABC-123",       .ci),
            
        ]
        
        for testCase in testCases {
            XCTAssertEqual(GitHubFlow.Branch.defaultParsingMethod(name: testCase.input), testCase.expected, line: testCase.line)
        }
        
    }
    
}
