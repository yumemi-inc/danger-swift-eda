//
//  EdaTests.swift
//  
//
//  Created by 史 翔新 on 2021/11/29.
//

import Foundation
import XCTest
import Danger
@testable import DangerSwiftHammer
@testable import DangerSwiftShoki
@testable import DangerSwiftEda

final class EdaTests: XCTestCase {
    
    private struct EdaResolver {
        
        var headBranch: Branch = .makeDevelop()
        var baseBranch: Branch = .makeMain()
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
            .init(
                headBranchResolver: { headBranch },
                baseBranchResolver: { baseBranch },
                additionLinesResolver: { additionLines },
                deletionLinesResolver: { deletionLines },
                modifiedFilesResolver: { modifiedFiles },
                commitsResolver: { commits },
                hammerResolver: { .dummy(container: hammerShellCommandContainer) },
                shokiResolver: { .dummy(container: shokiMessageContainer) },
                messageExecutor: { [unowned container = edaMessageContainer] in container.string = $0 },
                warnExecutor: { [unowned container = edaWarningContainer] in container.string = $0 },
                failExecutor: { [unowned container = edaFailureContainer] in container.string = $0 }
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
            let edaResolver = EdaResolver(baseBranch: .makeMain())
            let eda = edaResolver.makeEda()
            var result = CheckResult.dummy()
            precondition(result.warningsCount == 0)
            precondition(result.errorsCount == 0)
            precondition(result.markdownMessage == "")
            
            eda.checkBaseBranch(expected: [.main], into: &result)
            XCTAssertEqual(result.warningsCount, 0)
            XCTAssertEqual(result.errorsCount, 0)
            XCTAssertEqual(result.markdownMessage, """
                Checking Item | Result
                | ---| --- |
                Base Branch Check | :tada:
                """)
        }
        
        XCTContext.runActivity(named: "Invalid Base Branch Check") { _ in
            let edaResolver = EdaResolver(baseBranch: .makeMain())
            let eda = edaResolver.makeEda()
            var result = CheckResult.dummy()
            precondition(result.warningsCount == 0)
            precondition(result.errorsCount == 0)
            precondition(result.markdownMessage == "")
            
            eda.checkBaseBranch(expected: [.develop], into: &result)
            XCTAssertEqual(result.warningsCount, 0)
            XCTAssertEqual(result.errorsCount, 1)
            XCTAssertEqual(result.markdownMessage, """
                Checking Item | Result
                | ---| --- |
                Base Branch Check | :no_good:
                """)
        }
        
    }
    
    func test_checkNoMergeCommitsIncluded() {
        
        XCTContext.runActivity(named: "Valid Commits Check") { _ in
            let edaResolver = EdaResolver(commits: [
                .dummy(sha: "", author: .dummy(name: "", email: "", date: ""), committer: .dummy(name: "", email: "", date: ""), message: "", parents: ["1"], url: nil),
                .dummy(sha: "", author: .dummy(name: "", email: "", date: ""), committer: .dummy(name: "", email: "", date: ""), message: "", parents: ["A"], url: nil),
            ])
            let eda = edaResolver.makeEda()
            var result = CheckResult.dummy()
            precondition(result.warningsCount == 0)
            precondition(result.errorsCount == 0)
            precondition(result.markdownMessage == "")
            
            eda.checkNoMergeCommitsIncluded(into: &result)
            XCTAssertEqual(result.warningsCount, 0)
            XCTAssertEqual(result.errorsCount, 0)
            XCTAssertEqual(result.markdownMessage, """
                Checking Item | Result
                | ---| --- |
                Merge Commit Non-Existence Check | :tada:
                """)
        }
        
        XCTContext.runActivity(named: "Invalid Commits Check") { _ in
            let edaResolver = EdaResolver(commits: [
                .dummy(sha: "", author: .dummy(name: "", email: "", date: ""), committer: .dummy(name: "", email: "", date: ""), message: "", parents: ["1"], url: nil),
                .dummy(sha: "", author: .dummy(name: "", email: "", date: ""), committer: .dummy(name: "", email: "", date: ""), message: "", parents: ["A", "B"], url: nil),
            ])
            let eda = edaResolver.makeEda()
            var result = CheckResult.dummy()
            precondition(result.warningsCount == 0)
            precondition(result.errorsCount == 0)
            precondition(result.markdownMessage == "")
            
            eda.checkNoMergeCommitsIncluded(into: &result)
            XCTAssertEqual(result.warningsCount, 0)
            XCTAssertEqual(result.errorsCount, 1)
            XCTAssertEqual(result.markdownMessage, """
                Checking Item | Result
                | ---| --- |
                Merge Commit Non-Existence Check | :no_good:
                """)
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
    
    static func dummy(container: StringContainer) -> Hammer {
        
        .init(
            baseBranchResolver: { "" },
            shellCommandExecutor: { [unowned container] in container.string = $0; return "executed" })
        
    }
    
}

private extension Shoki {
    
    static func dummy(container: StringContainer) -> Shoki {
        
        .init(
            markdownExecutor: { _ in },
            messageExecutor: { [unowned container] in container.string = $0 }
        )
        
    }
    
}

private extension CheckResult {
    
    static func dummy(title: String = "Test") -> CheckResult {
        
        .init(title: title)
        
    }
    
}

private extension XCTestCase {
    
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

private final class StringContainer {
    
    var string: String
    
    init(string: String = "") {
        self.string = string
    }
    
}
