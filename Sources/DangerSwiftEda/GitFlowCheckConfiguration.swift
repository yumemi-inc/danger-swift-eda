//
//  GitFlowCheckConfiguration.swift
//  
//
//  Created by 史 翔新 on 2021/11/15.
//

import Foundation

public struct GitFlowCheckConfiguration {
    
    public enum ChangeLogUpdateRequirement {
        case no
        case yes(path: String)
    }
    
    public enum VersionUpdateRequirement {
        case no
        case yes(path: String, keyword: String)
    }
    
    public var acceptMergeCommitsInFeaturePRs: Bool = false
    public var recommendMaxDiffAmountInFeaturePRs: Int = 300
    public var recommendChangeLogUpdate: ChangeLogUpdateRequirement = .yes(path: "CHANGELOG.md")
    public var requiresVersionModificationInReleasePRs: VersionUpdateRequirement = .no
    public var ticketAddressResolver: ((String) -> String)?
    
    public static var `default`: GitFlowCheckConfiguration {
        .init()
    }
    
}
