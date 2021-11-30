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
    
    func test_resolvedPropertiesAndExecutions() {
        
        let author = Git.Commit.Author.dummy(name: "abc", email: "xyz", date: "123")
        let committer = Git.Commit.Author.dummy(name: "def", email: "opq", date: "456")
        let commit = Git.Commit.dummy(sha: "asd", author: author, committer: committer, message: "qwerty", parents: ["qaz", "wsx"], url: nil)
        let hammerShellCommandContainer = StringContainer()
        let shokiMessageContainer = StringContainer()
        let edaMessageContainer = StringContainer()
        let edaWarningContainer = StringContainer()
        let edaFailureContainer = StringContainer()
        
        let headBranch = Branch.makeDevelop()
        let baseBranch = Branch.makeMain()
        let additionLines = 100
        let deletionLines = 200
        let modifiedFiles = ["abc.efg"]
        let commits = [commit]
        let hammer = Hammer.dummy(container: hammerShellCommandContainer)
        let shoki = Shoki.dummy(container: shokiMessageContainer)
        
        let eda = Eda(
            headBranchResolver: { headBranch },
            baseBranchResolver: { baseBranch },
            additionLinesResolver: { additionLines },
            deletionLinesResolver: { deletionLines },
            modifiedFilesResolver: { modifiedFiles },
            commitsResolver: { commits },
            hammerResolver: { hammer },
            shokiResolver: { shoki },
            messageExecutor: { [unowned container = edaMessageContainer] in container.string = $0 },
            warnExecutor: { [unowned container = edaWarningContainer] in container.string = $0 },
            failExecutor: { [unowned container = edaFailureContainer] in container.string = $0 }
        )
        
        XCTAssertEqual(eda.headBranch, headBranch)
        XCTAssertEqual(eda.baseBranch, baseBranch)
        XCTAssertEqual(eda.additionLines, additionLines)
        XCTAssertEqual(eda.deletionLines, deletionLines)
        XCTAssertEqual(eda.modifiedFiles, modifiedFiles)
        XCTAssertEqual(eda.commits, commits)
        XCTAssert(hammer: hammer, container: hammerShellCommandContainer, line: #line)
        XCTAssert(shoki: shoki, container: shokiMessageContainer, line: #line)
        XCTAssert(stringExecution: eda.message(_:), container: edaMessageContainer, line: #line)
        XCTAssert(stringExecution: eda.warn(_:), container: edaWarningContainer, line: #line)
        XCTAssert(stringExecution: eda.fail(_:), container: edaFailureContainer, line: #line)
        
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

private extension XCTestCase {
    
    func XCTAssert(hammer: Hammer, container: StringContainer, line: UInt) {
        
        container.string = "initial"
        precondition(container.string == "initial")
        
        XCTAssertEqual(hammer.shellCommandExecutor("new"), "executed", line: line)
        XCTAssertEqual(container.string, "new")
        
    }
    
    func XCTAssert(shoki: Shoki, container: StringContainer, line: UInt) {
        
        container.string = "initial"
        precondition(container.string == "initial")
        
        shoki.message("new")
        XCTAssertEqual(container.string, "new", line: line)
        
    }
    
    func XCTAssert(stringExecution: (String) -> Void, container: StringContainer, line: UInt) {
        
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
