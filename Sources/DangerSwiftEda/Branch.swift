//
//  Branch.swift
//
//
//  Created by 史 翔新 on 2020/07/11.
//

import OctoKit

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
    
    public static func parsed(from branchName: String) -> Branch? {
        switch branchName {
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
