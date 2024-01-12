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
    
    @available(*, deprecated, renamed: "init(configuration:)")
    public init(_ configuration: Configuration) {
        self.init(configuration: configuration)
    }
    
}

// MARK: - Methods for single check items
extension GitFlow {
    
    // Check whether base branch is correct or not
    private func checkBaseBranch(in pr: PRMetaData, validation: (Branch) -> Bool, into report: inout Report, using utility: PRUtility) {
        
        let doBaseBranchCheckTitle = "Base Branch Check"
        utility.check(doBaseBranchCheckTitle, into: &report) {
            guard let baseBranch = configuration.branchParsingMethod(pr.baseBranchName) else {
                assertionFailure("Failed to get base branch")
                return .rejected(failureMessage: "Invalid base branch")
            }
            
            if validation(baseBranch) {
                return .good
                
            } else {
                return .rejected(failureMessage: "Invalid base branch")
            }
        }
        
    }
    
    // Check whether the PR contains merge commits or not
    func checkNoMergeCommitsIncluded(in pr: PRMetaData, into report: inout Report, using utility: PRUtility) {
        
        let doNoMergeCommitsCheckTitle = "Merge Commit Non-Existence Check"
        utility.check(doNoMergeCommitsCheckTitle, into: &report) {
            if pr.commits.allSatisfy({ !$0.isMergeCommit }) {
                return .good
                
            } else {
                return .rejected(failureMessage: "Don't include any merge commits in this PR. Please consider rebasing if needed.")

            }
        }
        
    }
    
    // Check whether the PR volume is less than a given number
    func checkDiffAmount(in pr: PRMetaData, lessThan maxAmountOfModifiedLines: Int, into report: inout Report, using utility: PRUtility) {
        
        let doDiffAmountCheckTitle = "Diff Volume Check"
        utility.check(doDiffAmountCheckTitle, into: &report) {
            if pr.modifiedLines < maxAmountOfModifiedLines {
                return .good
                
            } else {
                return .acceptable(warningMessage: "There's too much diff. Please make PRs smaller.")
            }
        }
        
    }
    
    // Check whether ChangeLog has been modified or not
    func checkChangeLogModification(in pr: PRMetaData, filePath: String, into report: inout Report, using utility: PRUtility) {
        
        let doChangeLogModificationCheckTitle = "ChangeLog Modification Check"
        let hasChangeLogBeenModified = pr.hasModifiedFile(at: filePath)
        
        utility.check(doChangeLogModificationCheckTitle, into: &report) {
            if hasChangeLogBeenModified {
                return .good
                
            } else {
                return .acceptable(warningMessage: "This PR doesn't contain any modifications at \(filePath). Please consider to update the ChangeLog.")
            }
        }
        
    }
    
    // Check whether Version has been modified or not
    func checkVersionModification(in pr: PRMetaData, filePath: String, by keyword: String, into report: inout Report, using utility: PRUtility) {
        
        let hasMarketingVersionBeenModified = pr.hasModifiedContent(keyword, at: filePath)
        let doVersionModificationCheckTitle = "Version Modification Check"
        utility.check(doVersionModificationCheckTitle, into: &report) {
            if hasMarketingVersionBeenModified {
                return .acceptable(warningMessage: "Please check whether the version modification is correct or not.")
                
            } else {
                return .rejected(failureMessage: "This PR doesn't contain any version modification, which is required.")
            }
        }
        
        if hasMarketingVersionBeenModified {
            utility.askReviewer(to: doVersionModificationCheckTitle, into: &report)
        }
    }
    
    // Ask reviewers to check whether CI auto generated diff is valid or not
    func checkCIAutoPRModification(into report: inout Report, using utility: PRUtility) {
        
        utility.askReviewer(to: "Check whether CI's auto-generated PR is valid or not", into: &report)
        utility.warn("This PR is auto-generated by CI service. Please check if the diff is valid or not.")
        
    }
    
    // Ask reviewers to check whether all required tasks are closed
    func checkRemainedTasksState(into report: inout Report, using utility: PRUtility) {
        
        utility.askReviewer(to: "Remained Task Check", into: &report)
        utility.warn("Please check whether all required tickets and issues are closed or not.")
        
    }
}

// MARK: - Methods for each workflow of PRs
extension GitFlow {
    
    func doCIServicePRCheck(against pr: PRMetaData, using utility: PRUtility) -> Report {
        
        var report = utility.makeInitialReport(title: "CI Service PR Check")
        
        checkBaseBranch(in: pr, validation: { $0 == .develop }, into: &report, using: utility)
        
        // CI auto-generated PRs should not contain any merge commits at first place.
        checkNoMergeCommitsIncluded(in: pr, into: &report, using: utility)
        
        checkCIAutoPRModification(into: &report, using: utility)
        
        return report
        
    }
    
    func doFeaturePRCheck(against pr: PRMetaData, using utility: PRUtility) -> Report {
        
        var report = utility.makeInitialReport(title: "Feature PR Check")
        
        checkBaseBranch(in: pr, validation: { $0 == .develop }, into: &report, using: utility)
        
        if !configuration.acceptsMergeCommitsInFeaturePRs {
            checkNoMergeCommitsIncluded(in: pr, into: &report, using: utility)
        }
        
        checkDiffAmount(in: pr, lessThan: configuration.recommendedMaxDiffAmountInFeaturePRs, into: &report, using: utility)
        
        if case .yes(path: let filePath) = configuration.suggestsChangeLogUpdate {
            checkChangeLogModification(in: pr, filePath: filePath, into: &report, using: utility)
        }
        
        return report
        
    }
    
    func doReleasePRCheck(against pr: PRMetaData, using utility: PRUtility) -> Report {
        
        var report = utility.makeInitialReport(title: "Release PR Check")
        
        // Release PRs should be merged both to main and develop branch
        checkBaseBranch(in: pr, validation: { $0 == .main || $0 == .develop }, into: &report, using: utility)
        let baseBranch = configuration.branchParsingMethod(pr.baseBranchName)
        switch baseBranch {
        case .main:
            utility.askReviewer(to: "Please make sure you've also created another PR to develop branch", into: &report)
            
        case .develop:
            utility.askReviewer(to: "Please make sure you've also created another PR to main branch", into: &report)
            
        default:
            break
        }
        
        if baseBranch == .develop {
            // If it's merging to develop branch, there should be no merge commits in the PR
            checkNoMergeCommitsIncluded(in: pr, into: &report, using: utility)
            
            // If it's merging to develop branch, since there should be only version related modifications, diff volume should be less than 100 lines
            checkDiffAmount(in: pr, lessThan: 100, into: &report, using: utility)
        }
        
        checkRemainedTasksState(into: &report, using: utility)
        
        if case .yes(let filePath, let keyword) = configuration.requiresVersionModificationInReleasePRs {
            checkVersionModification(in: pr, filePath: filePath, by: keyword, into: &report, using: utility)
        }
        
        return report
        
    }
    
    func doHotFixPRCheck(against pr: PRMetaData, using utility: PRUtility) -> Report {
        
        var report = utility.makeInitialReport(title: "HotFix PR Check")
        
        // HotFix PRs should be merged both to main and develop branch
        checkBaseBranch(in: pr, validation: { $0 == .main || $0 == .develop }, into: &report, using: utility)
        let baseBranch = configuration.branchParsingMethod(pr.baseBranchName)
        switch baseBranch {
        case .main:
            utility.askReviewer(to: "Please make sure you've also created another PR to develop branch", into: &report)
            
        case .develop:
            utility.askReviewer(to: "Please make sure you've also created another PR to main branch", into: &report)
            
        default:
            break
        }
        
        // HotFix PRs should not contain any merge commits at first place.
        checkNoMergeCommitsIncluded(in: pr, into: &report, using: utility)
        
        checkDiffAmount(in: pr, lessThan: configuration.recommendedMaxDiffAmountInFeaturePRs, into: &report, using: utility)
        
        if case .yes(path: let filePath) = configuration.suggestsChangeLogUpdate {
            checkChangeLogModification(in: pr, filePath: filePath, into: &report, using: utility)
        }
        
        return report
        
    }
    
}

// MARK: - GitFlow Check
extension GitFlow: PRWorkflow {
    
    public enum FlowError: Error {
        case invalidHeadBranch(name: String)
        case illegalHeadBranch(Branch)
    }
    
    public func doWorkflowCheck(against pr: PRMetaData, using utility: PRUtility) throws -> Report {
        
        let headBranchName = pr.headBranchName
        guard let headBranch = configuration.branchParsingMethod(headBranchName) else {
            throw FlowError.invalidHeadBranch(name: headBranchName)
        }
        
        switch headBranch {
        case .ci:
            return doCIServicePRCheck(against: pr, using: utility)
            
        case .feature:
            return doFeaturePRCheck(against: pr, using: utility)
            
        case .release:
            return doReleasePRCheck(against: pr, using: utility)
            
        case .hotfix:
            return doHotFixPRCheck(against: pr, using: utility)
            
        case .main, .develop:
            throw FlowError.illegalHeadBranch(headBranch)
        }
   

    }
    
}

// MARK: - Convenient Extensions
extension GitFlow.Branch {
    
    public static func defaultParsingMethod(name: String) -> Self? {
        
        switch name {
        case "main", "master":
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
