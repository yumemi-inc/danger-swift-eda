//
//  Branch.swift
//
//
//  Created by 史 翔新 on 2020/07/11.
//

import OctoKit

public struct Branch: Equatable {
    
    public enum BranchType: Equatable {
        case main
        case develop
        case feature
        case release
        case hotfix
        case ci
    }
    
    public enum Reference: Equatable {
        case issue(String)
        case ticket(String)
    }
    
    public let type: BranchType
    public let reference: Reference?
    
    init(type: BranchType, reference: Reference?) {
        
        switch type {
        case .main, .develop, .ci:
            assert(reference == nil)
            
        case .feature, .hotfix, .release:
            break
        }
        
        self.type = type
        self.reference = reference
        
    }
    
    static func makeMain() -> Branch {
        .init(type: .main, reference: nil)
    }
    
    static func makeDevelop() -> Branch {
        .init(type: .develop, reference: nil)
    }
    
    static func makeFeature(_ reference: Reference?) -> Branch {
        .init(type: .feature, reference: reference)
    }
    
    static func makeHotfix(_ reference: Reference?) -> Branch {
        .init(type: .hotfix, reference: reference)
    }
    
    static func makeRelease(_ reference: Reference?) -> Branch {
        .init(type: .release, reference: reference)
    }
    
    static func makeCI() -> Branch {
        .init(type: .ci, reference: nil)
    }
    
    public static func parsed(from branchName: String) -> Branch? {
        switch branchName {
        case "main":
            return .makeMain()
            
        case "develop":
            return .makeDevelop()
            
        case let hotfix where hotfix.contains(pattern: #"\bhotfix\b[/-]"#):
            return .makeHotfix(hotfix.extractingReference())
            
        case let feature where feature.contains(pattern: #"\bfeature\b[/-]"#):
            return .makeFeature(feature.extractingReference())
            
        case let release where release.contains(pattern: #"\brelease\b[/-]"#):
            return .makeRelease(release.extractingReference())
            
        case let ci where ci.contains(pattern: #"\bci\b[/-]"#):
            return .makeCI()
            
        case _:
            return nil
        }
        
    }
    
}

private extension String {
    
    private func extractingIssue() -> Branch.Reference? {
        
        if let issueID = substring(ofPattern: #"\bissue\b[/-](\d+)"#) {
            return .issue(issueID)
            
        } else {
            return nil
        }
        
    }
    
    private func extractingTicket() -> Branch.Reference? {
        
        if let ticketID = substring(ofPattern: #"\bticket\b[/-](.+)"#) {
            return .ticket(ticketID)
            
        } else {
            return nil
        }
        
    }
    
    func extractingReference() -> Branch.Reference? {
        
        return extractingIssue() ?? extractingTicket()
        
    }
    
}
