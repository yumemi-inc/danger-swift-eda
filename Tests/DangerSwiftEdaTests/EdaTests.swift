//
//  EdaTests.swift
//  
//
//  Created by 史 翔新 on 2021/11/29.
//

import Foundation
import XCTest
import Danger
import DangerSwiftHammer
import DangerSwiftShoki
@testable import DangerSwiftEda

final class EdaTests: XCTestCase {
    
    private struct EdaResolver {
        
        var headBranch: Branch = .develop
        var baseBranch: Branch = .main
        var additionLines: Int = 100
        var deletionLines: Int = 200
        var modifiedFiles: [String] = ["abc.efg"]
        var commits: [Git.Commit] = [
            .dummy(
                sha: "asd",
                author: .dummy(name: "abc", email: "xyz", date: "123"),
                committer: .dummy(name: "def", email: "opq", date: "456"),
                message: "qwerty",
                parents: ["qaz", "wsx"],
                url: nil
            )
        ]
        
        var hammerShellCommandContainer: StringContainer = .init()
        var shokiMessageContainer: StringContainer = .init()
        var edaMessageContainer: StringContainer = .init()
        var edaWarningContainer: StringContainer = .init()
        var edaFailureContainer: StringContainer = .init()
        
        func makeEda() -> Eda {
            
            func messageExecutor(container: StringContainer) -> (String) -> Void {
                { [unowned container] string in
                    container.string = string
                }
            }
            
            return .init(
                headBranchResolver: { headBranch },
                baseBranchResolver: { baseBranch },
                additionLinesResolver: { additionLines },
                deletionLinesResolver: { deletionLines },
                modifiedFilesResolver: { modifiedFiles },
                commitsResolver: { commits },
                hammerResolver: { .dummy(container: hammerShellCommandContainer) },
                shokiResolver: { .dummy(container: shokiMessageContainer) },
                messageExecutor: messageExecutor(container: edaMessageContainer),
                warnExecutor: messageExecutor(container: edaWarningContainer),
                failExecutor: messageExecutor(container: edaFailureContainer)
            )
            
        }
        
    }
    
    func test_resolvedPropertiesAndExecutions() {
        
        let edaResolver = EdaResolver()
        let eda = edaResolver.makeEda()
        
        XCTAssertEqual(eda.headBranch, edaResolver.headBranch)
        XCTAssertEqual(eda.baseBranch, edaResolver.baseBranch)
        XCTAssertEqual(eda.additionLines, edaResolver.additionLines)
        XCTAssertEqual(eda.deletionLines, edaResolver.deletionLines)
        XCTAssertEqual(eda.modifiedFiles, edaResolver.modifiedFiles)
        XCTAssertEqual(eda.commits, edaResolver.commits)
        XCTAssert(hammer: eda.hammer, container: edaResolver.hammerShellCommandContainer)
        XCTAssert(shoki: eda.shoki, container: edaResolver.shokiMessageContainer)
        XCTAssert(stringExecution: eda.message(_:), container: edaResolver.edaMessageContainer)
        XCTAssert(stringExecution: eda.warn(_:), container: edaResolver.edaWarningContainer)
        XCTAssert(stringExecution: eda.fail(_:), container: edaResolver.edaFailureContainer)
        
    }
    
    func test_checkBaseBranch() {
        
        XCTContext.runActivity(named: "Valid Base Branch Check") { _ in
            let edaResolver = EdaResolver(baseBranch: .main)
            let eda = edaResolver.makeEda()
            let shoki = eda.shoki
            var edaReport = shoki.dummyReport()
            var manualReport = edaReport
            
            eda.checkBaseBranch(validation: { $0 == .main }, into: &edaReport)
            shoki.check("Base Branch Check", into: &manualReport, execution: { .good })
            XCTAssertEqual(edaReport, manualReport)
        }
        
        XCTContext.runActivity(named: "Invalid Base Branch Check") { _ in
            let edaResolver = EdaResolver(baseBranch: .main)
            let eda = edaResolver.makeEda()
            let shoki = eda.shoki
            var edaReport = shoki.dummyReport()
            var manualReport = edaReport
            
            eda.checkBaseBranch(validation: { $0 == .develop }, into: &edaReport)
            shoki.check("Base Branch Check", into: &manualReport, execution: { .rejected(failureMessage: "Invalid base branch") })
            XCTAssertEqual(edaReport, manualReport)
        }
        
    }
    
    func test_checkNoMergeCommitsIncluded() {
        
        XCTContext.runActivity(named: "Valid Commits Check") { _ in
            let edaResolver = EdaResolver(commits: [
                .dummy(sha: "", author: .dummy(name: "", email: "", date: ""), committer: .dummy(name: "", email: "", date: ""), message: "", parents: ["1"], url: nil),
                .dummy(sha: "", author: .dummy(name: "", email: "", date: ""), committer: .dummy(name: "", email: "", date: ""), message: "", parents: ["A"], url: nil),
            ])
            let eda = edaResolver.makeEda()
            let shoki = eda.shoki
            var edaReport = shoki.dummyReport()
            var manualReport = edaReport
            
            eda.checkNoMergeCommitsIncluded(into: &edaReport)
            shoki.check("Merge Commit Non-Existence Check", into: &manualReport, execution: { .good })
            XCTAssertEqual(edaReport, manualReport)
        }
        
        XCTContext.runActivity(named: "Invalid Commits Check") { _ in
            let edaResolver = EdaResolver(commits: [
                .dummy(sha: "", author: .dummy(name: "", email: "", date: ""), committer: .dummy(name: "", email: "", date: ""), message: "", parents: ["1"], url: nil),
                .dummy(sha: "", author: .dummy(name: "", email: "", date: ""), committer: .dummy(name: "", email: "", date: ""), message: "", parents: ["A", "B"], url: nil),
            ])
            let eda = edaResolver.makeEda()
            let shoki = eda.shoki
            var edaReport = shoki.dummyReport()
            var manualReport = edaReport
            
            eda.checkNoMergeCommitsIncluded(into: &edaReport)
            shoki.check("Merge Commit Non-Existence Check", into: &manualReport, execution: { .rejected(failureMessage: "Don't include any merge commits in this PR. Please consider rebasing if needed.") })
            XCTAssertEqual(edaReport, manualReport)
        }
        
    }
    
}

private extension Git.Commit.Author {
    
    static func dummy(name: String, email: String, date: String) -> Git.Commit.Author {
        
        let dict: [String: Any] = [
            "name": name,
            "email": email,
            "date": date,
        ]
        let dictData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        return try! JSONDecoder().decode(Git.Commit.Author.self, from: dictData)
        
    }
    
    var dict: [String: Any] {
        [
            "name": name,
            "email": email,
            "date": date,
        ]
    }
    
}

private extension Git.Commit {
    
    static func dummy(sha: String?, author: Author, committer: Author, message: String, parents: [String]?, url: String?) -> Git.Commit {
        
        let dict: [String: Any] = [
            "sha": sha as Any,
            "author": author.dict,
            "committer": committer.dict,
            "message": message,
            "parents": parents as Any,
            "url": url as Any,
        ]
        let dictData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        return try! JSONDecoder().decode(Git.Commit.self, from: dictData)
        
    }
    
}

private extension Hammer {
    
    static func dummy(container: XCTestCase.StringContainer) -> Hammer {
        
        .init(
            baseBranch: { "" },
            shellCommand: { [unowned container] in container.string = $0; return "executed" })
        
    }
    
}

private extension Shoki {
    
    static func dummy(container: XCTestCase.StringContainer) -> Shoki {
        
        .init(
            markdown: { _ in XCTFail() },
            message: { [unowned container] in container.string = $0 },
            warning: { _ in XCTFail() },
            failure: { _ in XCTFail() }
        )
        
    }
    
    func dummyReport(title: String = "Test") -> Report {
        
        makeInitialReport(title: title)
        
    }
    
}
