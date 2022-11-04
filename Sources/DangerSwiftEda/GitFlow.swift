//
//  GitFlow.swift
//  
//
//  Created by 史 翔新 on 2021/11/15.
//

import Foundation
import DangerSwiftShoki

// MARK: - GitFlow Declaration
public struct GitFlow {
    
    public enum Branch: Equatable {
        
        public enum Reference: Equatable {
            case issue(String)
            case ticket(String)
        }
        
        case main
        case develop
        case feature(Reference?)
        case release(Reference?)
        case hotfix(Reference?)
        case ci
        
        public var reference: Reference? {
            
            switch self {
            case .main,
                 .develop,
                 .ci:
                return nil
                
            case .feature(let reference),
                 .release(let reference),
                 .hotfix(let reference):
                return reference
            }
            
        }
        
    }
    
    public struct Configuration {
        
        public enum ChangeLogUpdateRequirement {
            case no
            case yes(path: String)
        }
        
        public enum VersionUpdateRequirement {
            case no
            case yes(path: String, keyword: String)
        }
        
        public var branchParsingMethod: (String) -> GitFlow.Branch?
        public var acceptsMergeCommitsInFeaturePRs: Bool
        public var recommendedMaxDiffAmountInFeaturePRs: Int
        public var suggestsChangeLogUpdate: ChangeLogUpdateRequirement
        public var requiresVersionModificationInReleasePRs: VersionUpdateRequirement
        public var ticketAddressResolver: ((String) -> String)?
        
        public init(
            branchParsingMethod: @escaping (String) -> GitFlow.Branch? = GitFlow.Branch.defaultParsingMethod(name:),
            acceptsMergeCommitsInFeaturePRs: Bool = false,
            recommendedMaxDiffAmountInFeaturePRs: Int = 300,
            suggestsChangeLogUpdate: ChangeLogUpdateRequirement = .yes(path: "CHANGELOG.md"),
            requiresVersionModificationInReleasePRs: VersionUpdateRequirement = .no,
            ticketAddressResolver: ((String) -> String)? = nil
        ) {
            self.branchParsingMethod = branchParsingMethod
            self.acceptsMergeCommitsInFeaturePRs = acceptsMergeCommitsInFeaturePRs
            self.recommendedMaxDiffAmountInFeaturePRs = recommendedMaxDiffAmountInFeaturePRs
            self.suggestsChangeLogUpdate = suggestsChangeLogUpdate
            self.requiresVersionModificationInReleasePRs = requiresVersionModificationInReleasePRs
            self.ticketAddressResolver = ticketAddressResolver
        }
        
        public static var `default`: Configuration {
            .init()
        }
        
    }
    
    public var configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
}

// MARK: - Convenient Extensions
extension GitFlow.Branch {
    
    public static func defaultParsingMethod(name: String) -> Self? {
        
        switch name {
        case "main":
            return .main
            
        case "develop":
            return .develop
            
        case let hotfix where hotfix.contains(pattern: #"\bhotfix\b[/-]"#):
            return .hotfix(hotfix.extractingReference())
            
        case let feature where feature.contains(pattern: #"\bfeature\b[/-]"#):
            return .feature(feature.extractingReference())
            
        case let release where release.contains(pattern: #"\brelease\b[/-]"#):
            return .release(release.extractingReference())
            
        case let ci where ci.contains(pattern: #"\bci\b[/-]"#):
            return .ci
            
        case _:
            return nil
        }
        
    }
    
}

private extension String {
    
    private func extractingIssue() -> GitFlow.Branch.Reference? {
        
        if let issueID = substring(ofPattern: #"\bissue\b[/-](\d+)"#) {
            return .issue(issueID)
            
        } else {
            return nil
        }
        
    }
    
    private func extractingTicket() -> GitFlow.Branch.Reference? {
        
        if let ticketID = substring(ofPattern: #"\bticket\b[/-](.+)"#) {
            return .ticket(ticketID)
            
        } else {
            return nil
        }
        
    }
    
    func extractingReference() -> GitFlow.Branch.Reference? {
        
        return extractingIssue() ?? extractingTicket()
        
    }
    
}
