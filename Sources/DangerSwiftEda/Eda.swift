//
//  Eda.swift
//  
//
//  Created by 史 翔新 on 2021/11/15.
//

import Foundation
import DangerSwiftShoki

// MARK: - Eda Declaration

// MARK: resolvers and executors
public struct Eda {
    public static var gitHostingInstance: GitHostingInstance?

    private let prMetaDataResolver: () -> PRMetaData
    private let prUtilityResolver: () -> PRUtility
    private let shokiResolver: () -> Shoki
    
    init(
        prMetaDataResolver: @escaping () -> PRMetaData,
        prUtilityResolver: @escaping () -> PRUtility,
        shokiResolver: @escaping () -> Shoki
    ) {
        self.prMetaDataResolver = prMetaDataResolver
        self.prUtilityResolver = prUtilityResolver
        self.shokiResolver = shokiResolver
    }
    
}

// MARK: - Eda Methods for PR Checking
extension Eda {
    
    @available(*, deprecated, renamed: "checkPR(workflow:)")
    public func ckeckPR<Workflow: PRWorkflow>(workflow: Workflow) {
        checkPR(workflow: workflow)
    }
    
    public func checkPR<Workflow: PRWorkflow>(workflow: Workflow) {
        
        let metadata = prMetaDataResolver()
        let utility = prUtilityResolver()
        let shoki = shokiResolver()
        
        if metadata.customGitHostingInstance == nil {
            utility.message("local PR Check: skip")
            return
        }
        do {
            let report = try workflow.doWorkflowCheck(against: metadata, using: utility)
            shoki.report(report)
            
        } catch {
            utility.fail("\(error)")
        }
        
    }
    
}
