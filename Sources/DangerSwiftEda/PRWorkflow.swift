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
