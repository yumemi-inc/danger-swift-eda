//
//  LibraryInternalMethodBridges.swift
//  
//
//  Created by 史 翔新 on 2021/12/07.
//

@testable import DangerSwiftHammer
@testable import DangerSwiftShoki

extension Hammer {
    
    init(baseBranch: @escaping () -> String, shellCommand: @escaping (String) -> String) {
        self = .init(baseBranchResolver: baseBranch, shellCommandExecutor: shellCommand)
    }
    
}

extension Shoki {
    
    init(markdown: @escaping (String) -> Void, message: @escaping (String) -> Void, warning: @escaping (String) -> Void, failure: @escaping (String) -> Void) {
        self = .init(markdownExecutor: markdown, messageExecutor: message, warningExecutor: warning, failureExecutor: failure)
    }
    
}
