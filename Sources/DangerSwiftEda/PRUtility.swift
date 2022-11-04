//
//  PRUtility.swift
//  
//
//  Created by 史 翔新 on 2022/10/27.
//

import Foundation
import DangerSwiftShoki

public struct PRUtility {
    
    private let initialReportGenerator: (String) -> Report
    private let checkExecutor: (String, inout Report, () -> Report.CheckItem.Result) -> Void
    private let todoExecutor: (String, inout Report) -> Void
    
    private let messageExecutor: (String) -> Void
    private let warnExecutor: (String) -> Void
    private let failExecutor: (String) -> Void
    
    init(
        initialReportGenerator: @escaping (String) -> Report,
        checkExecutor: @escaping  (String, inout Report, () -> Report.CheckItem.Result) -> Void,
        todoExecutor: @escaping (String, inout Report) -> Void,
        messageExecutor: @escaping (String) -> Void,
        warnExecutor: @escaping (String) -> Void,
        failExecutor: @escaping (String) -> Void
    ) {
        self.initialReportGenerator = initialReportGenerator
        self.checkExecutor = checkExecutor
        self.todoExecutor = todoExecutor
        self.messageExecutor = messageExecutor
        self.warnExecutor = warnExecutor
        self.failExecutor = failExecutor
    }
    
}

extension PRUtility {
    
    public func makeInitialReport(title: String) -> Report {
        initialReportGenerator(title)
    }
    
    public func check(_ title: String, into report: inout Report, execution: () -> Report.CheckItem.Result) {
        checkExecutor(title, &report, execution)
    }
    
    public func askReviewer(to taskToDo: String, into report: inout Report) {
        todoExecutor(taskToDo, &report)
    }
    
    public func message(_ message: String) {
        messageExecutor(message)
    }
    
    public func warn(_ message: String) {
        warnExecutor(message)
    }
    
    public func fail(_ message: String) {
        failExecutor(message)
    }
    
}
