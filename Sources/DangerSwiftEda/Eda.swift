//
//  Eda.swift
//  
//
//  Created by 史 翔新 on 2021/11/15.
//

import Foundation
import DangerSwiftShoki
import DangerSwiftHammer

// MARK: - Eda Declaration

// MARK: resolvers and executors
public struct Eda {
    
    private let headBranchResolver: () -> Branch?
    private let baseBranchResolver: () -> Branch?
    
    private let additionLinesResolver: () -> Int
    private let deletionLinesResolver: () -> Int
    private let modifiedFilesResolver: () -> [String]
    
    private let commitsResolver: () -> [GitCommit]
    
    private let hammerResolver: () -> Hammer
    private let shokiResolver: () -> Shoki
    
    private let messageExecutor: (String) -> Void
    private let warnExecutor: (String) -> Void
    private let failExecutor: (String) -> Void
    
    init(
        headBranchResolver: @escaping () -> Branch?,
        baseBranchResolver: @escaping () -> Branch?,
        additionLinesResolver: @escaping () -> Int,
        deletionLinesResolver: @escaping () -> Int,
        modifiedFilesResolver: @escaping () -> [String],
        commitsResolver: @escaping () -> [GitCommit],
        hammerResolver: @escaping () -> Hammer,
        shokiResolver: @escaping () -> Shoki,
        messageExecutor: @escaping (String) -> Void,
        warnExecutor: @escaping (String) -> Void,
        failExecutor: @escaping (String) -> Void
    ) {
        self.headBranchResolver = headBranchResolver
        self.baseBranchResolver = baseBranchResolver
        self.additionLinesResolver = additionLinesResolver
        self.deletionLinesResolver = deletionLinesResolver
        self.modifiedFilesResolver = modifiedFilesResolver
        self.commitsResolver = commitsResolver
        self.hammerResolver = hammerResolver
        self.shokiResolver = shokiResolver
        self.messageExecutor = messageExecutor
        self.warnExecutor = warnExecutor
        self.failExecutor = failExecutor
    }
    
}

// MARK: resolved properties and executions
extension Eda {
    
    var headBranch: Branch? {
        headBranchResolver()
    }
    
    var baseBranch: Branch? {
        baseBranchResolver()
    }
    
    var additionLines: Int {
        additionLinesResolver()
    }
    
    var deletionLines: Int {
        deletionLinesResolver()
    }
    
    var modifiedFiles: [String] {
        modifiedFilesResolver()
    }
    
    var commits: [GitCommit] {
        commitsResolver()
    }
    
    var hammer: Hammer {
        hammerResolver()
    }
    
    var shoki: Shoki {
        shokiResolver()
    }
    
    func message(_ message: String) {
        messageExecutor(message)
    }
    
    func warn(_ message: String) {
        warnExecutor(message)
    }
    
    func fail(_ message: String) {
        failExecutor(message)
    }
    
}

// MARK: - Eda Properties for PR state display
extension Eda {
    
    private var modifiedLines: Int {
        additionLines + deletionLines
    }
    
    private func hasModifiedFile(at filePath: String) -> Bool {
        modifiedFiles.contains(where: { $0 == filePath })
    }
    
    private func hasModifiedContent(_ content: String, in filePath: String) -> Bool {
        hammer.diffLines(in: filePath).additions.contains(where: { $0.contains(content) })
    }
    
}

// MARK: - Eda Methods for single check items
extension Eda {
    
    // Check whether base branch is correct or not
    func checkBaseBranch(validation: (Branch) -> Bool, into report: inout Report) {
        
        let doBaseBranchCheckTitle = "Base Branch Check"
        report.check(doBaseBranchCheckTitle) {
            guard let baseBranch = baseBranch else {
                assertionFailure("Failed to get base branch")
                fail("Invalid base branch")
                return .rejected
            }
            
            if validation(baseBranch) {
                return .good
                
            } else {
                fail("Invalid base branch")
                return .rejected
            }
        }
        
    }
    
    // Check whether the PR contains merge commits or not
    func checkNoMergeCommitsIncluded(into report: inout Report) {
        
        let doNoMergeCommitsCheckTitle = "Merge Commit Non-Existence Check"
        report.check(doNoMergeCommitsCheckTitle) {
            if commits.allSatisfy({ !$0.isMergeCommit }) {
                return .good
                
            } else {
                fail("Don't include any merge commits in this PR. Please consider rebasing if needed.")
                return .rejected

            }
        }
        
    }
    
    // Check whether the PR volume is less than a given number
    func checkDiffAmount(lessThan maxAmountOfModifiedLines: Int, into report: inout Report) {
        
        let doDiffAmountCheckTitle = "Diff Volume Check"
        report.check(doDiffAmountCheckTitle) {
            if modifiedLines < maxAmountOfModifiedLines {
                return .good
                
            } else {
                warn("There's too much diff. Please make PRs smaller.")
                return .acceptable
            }
        }
        
    }
    
    // Check whether ChangeLog has been modified or not
    func checkChangeLogModification(at filePath: String, into report: inout Report) {
        
        let doChangeLogModificationCheckTitle = "ChangeLog Modification Check"
        let hasChangeLogBeenModified = hasModifiedFile(at: filePath)
        
        report.check(doChangeLogModificationCheckTitle) {
            if hasChangeLogBeenModified {
                return .good
                
            } else {
                warn("This PR doesn't contain any modifications in \(filePath). Please consider to update the ChangeLog.")
                return .acceptable
            }
        }
        
    }
    
    // Check whether Version has been modified or not
    func checkVersionModification(at filePath: String, by keyword: String, into report: inout Report) {
        
        let hasMarketingVersionBeenModified = hasModifiedContent(keyword, in: filePath)
        let doVersionModificationCheckTitle = "Version Modification Check"
        report.check(doVersionModificationCheckTitle) {
            if hasMarketingVersionBeenModified {
                warn("Please check whether the version modification is correct or not.")
                return .acceptable
                
            } else {
                fail("This PR doesn't contain any version modification, which is required.")
                return .rejected
            }
        }
        
        if hasMarketingVersionBeenModified {
            report.askReviewer(to: doVersionModificationCheckTitle)
        }
    }
    
    // Ask reviewers to check whether CI auto generated diff is valid or not
    func checkCIAutoPRModification(into report: inout Report) {
        
        report.askReviewer(to: "Check whether CI's auto-generated PR is valid or not")
        warn("This PR is auto-generated by CI service. Please check if the diff is valid or not.")
        
    }
    
    // Ask reviewers to check whether all required tasks are closed
    func checkRemainedTasksState(into report: inout Report) {
        
        report.askReviewer(to: "Remained Task Check")
        warn("Please check whether all required tickets and issues are closed or not.")
        
    }
}

// MARK: - Eda Methods for each workflow of PRs
extension Eda {
    
    func doCIServicePRCheck() -> Report {
        
        var report = Report(title: "CI Service PR Check")
        
        checkBaseBranch(validation: { $0 == .develop }, into: &report)
        
        // CI auto-generated PRs should not contain any merge commits at first place.
        checkNoMergeCommitsIncluded(into: &report)
        
        checkCIAutoPRModification(into: &report)
        
        return report
        
    }
    
    func doFeaturePRCheck(configuration: GitFlowCheckConfiguration) -> Report {
        
        var report = Report(title: "Feature PR Check")
        
        checkBaseBranch(validation: { $0 == .develop }, into: &report)
        
        if !configuration.acceptsMergeCommitsInFeaturePRs {
            checkNoMergeCommitsIncluded(into: &report)
        }
        
        checkDiffAmount(lessThan: configuration.recommendedMaxDiffAmountInFeaturePRs, into: &report)
        
        if case .yes(path: let filePath) = configuration.suggestsChangeLogUpdate {
            checkChangeLogModification(at: filePath, into: &report)
        }
        
        return report
        
    }
    
    func doReleasePRCheck(configuration: GitFlowCheckConfiguration) -> Report {
        
        var report = Report(title: "Release PR Check")
        
        // Release PRs should be merged both to main and develop branch
        checkBaseBranch(validation: { $0 == .main || $0 == .develop }, into: &report)
        switch baseBranch {
        case .main:
            report.askReviewer(to: "Please make sure you've also created another PR to develop branch")
            
        case .develop:
            report.askReviewer(to: "Please make sure you've also created another PR to main branch")
            
        default:
            break
        }
        
        if baseBranch == .develop {
            // If it's merging to develop branch, there should be no merge commits in the PR
            checkNoMergeCommitsIncluded(into: &report)
            
            // If it's merging to develop branch, since there should be only version related modifications, diff volume should be less than 100 lines
            checkDiffAmount(lessThan: 100, into: &report)
        }
        
        checkRemainedTasksState(into: &report)
        
        if case .yes(let filePath, let keyword) = configuration.requiresVersionModificationInReleasePRs {
            checkVersionModification(at: filePath, by: keyword, into: &report)
        }
        
        return report
        
    }
    
    func doHotFixPRCheck(configuration: GitFlowCheckConfiguration) -> Report {
        
        var report = Report(title: "HotFix PR Check")
        
        // HotFix PRs should be merged both to main and develop branch
        checkBaseBranch(validation: { $0 == .main || $0 == .develop }, into: &report)
        switch baseBranch {
        case .main:
            report.askReviewer(to: "Please make sure you've also created another PR to develop branch")
            
        case .develop:
            report.askReviewer(to: "Please make sure you've also created another PR to main branch")
            
        default:
            break
        }
        
        // HotFix PRs should not contain any merge commits at first place.
        checkNoMergeCommitsIncluded(into: &report)
        
        checkDiffAmount(lessThan: configuration.recommendedMaxDiffAmountInFeaturePRs, into: &report)
        
        if case .yes(path: let filePath) = configuration.suggestsChangeLogUpdate {
            checkChangeLogModification(at: filePath, into: &report)
        }
        
        return report
        
    }
    
}

// MARK: - Eda Methods for PR Checking
extension Eda {
    
    private enum PRWorkflowError: Error {
        case invalidBranchType
    }
    
    func report(configuration: GitFlowCheckConfiguration) throws {
        
        guard let headBranch = headBranch else {
            throw PRWorkflowError.invalidBranchType
        }
        
        if let reference = headBranch.reference {
            switch reference {
            case .issue(let issue):
                message("Resolve #\(issue)")
                
            case .ticket(let ticket):
                if let addressResolver = configuration.ticketAddressResolver {
                    message("Ticket: \(addressResolver(ticket))")
                }
            }
        }
        
        let report = try { (branch: Branch) throws -> Report in
            switch branch {
            case .ci:
                return doCIServicePRCheck()
                
            case .feature:
                return doFeaturePRCheck(configuration: configuration)
                
            case .release:
                return doReleasePRCheck(configuration: configuration)
                
            case .hotfix:
                return doHotFixPRCheck(configuration: configuration)
                
            case .main, .develop:
                throw PRWorkflowError.invalidBranchType
            }
        }(headBranch)
        
        shoki.report(report)
        
    }
    
    func doGitFlowPRCheck(configuration: GitFlowCheckConfiguration) {
        
        do {
            try report(configuration: configuration)
            
        } catch PRWorkflowError.invalidBranchType {
            fail("Failed to specify PR Workflow under GitFlow. Please check whether your head branch and base branch are correctly set or not.")
            
        } catch {
            fail("Unknown Error: \(error)")
        }
        
    }
    
    public func ckeckPR(workflow: PRWorkflow) {
        
        switch workflow {
        case .gitFlow(let configuration):
            doGitFlowPRCheck(configuration: configuration)
        }
        
    }
    
}
