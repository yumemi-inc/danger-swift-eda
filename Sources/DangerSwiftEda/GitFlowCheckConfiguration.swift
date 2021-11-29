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
    
    public var acceptsMergeCommitsInFeaturePRs: Bool
    public var recommendedMaxDiffAmountInFeaturePRs: Int
    public var suggestsChangeLogUpdate: ChangeLogUpdateRequirement
    public var requiresVersionModificationInReleasePRs: VersionUpdateRequirement
    public var ticketAddressResolver: ((String) -> String)?
    
    public init(
        acceptsMergeCommitsInFeaturePRs: Bool = false,
        recommendedMaxDiffAmountInFeaturePRs: Int = 300,
        suggestsChangeLogUpdate: ChangeLogUpdateRequirement = .yes(path: "CHANGELOG.md"),
        requiresVersionModificationInReleasePRs: VersionUpdateRequirement = .no,
        ticketAddressResolver: ((String) -> String)? = nil
    ) {
        self.acceptsMergeCommitsInFeaturePRs = acceptsMergeCommitsInFeaturePRs
        self.recommendedMaxDiffAmountInFeaturePRs = recommendedMaxDiffAmountInFeaturePRs
        self.suggestsChangeLogUpdate = suggestsChangeLogUpdate
        self.requiresVersionModificationInReleasePRs = requiresVersionModificationInReleasePRs
        self.ticketAddressResolver = ticketAddressResolver
    }
    
    public static var `default`: GitFlowCheckConfiguration {
        .init()
    }
    
}
