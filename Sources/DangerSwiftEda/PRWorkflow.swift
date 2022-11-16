//
//  PRWorkflow.swift
//  
//
//  Created by 史 翔新 on 2021/11/13.
//

import DangerSwiftShoki

public protocol PRWorkflow {
    func doWorkflowCheck(against info: PRMetaData, using utility: PRUtility) throws -> Report
}

public extension PRWorkflow where Self == GitFlow {
    
    static func gitFlow(configuration: GitFlow.Configuration = .default) -> Self {
        GitFlow(configuration: configuration)
    }
    
}

public extension PRWorkflow where Self == GitHubFlow {
    
    static func gitHubFlow(configuration: GitHubFlow.Configuration = .default) -> Self {
        GitHubFlow(configuration: configuration)
    }
    
}
