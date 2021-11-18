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
    
    var modifiedLines: Int {
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
    func checkBaseBranch(expected validBranchTypes: Set<Branch.BranchType>, into result: inout CheckResult) {
        
        let doBaseBranchCheckTitle = "Base Branch Check"
        result.check(doBaseBranchCheckTitle) {
            guard let baseBranch = baseBranch else {
                assertionFailure("Failed to get base branch")
                fail("Invalid base branch")
                return .rejected
            }
            
            if validBranchTypes.contains(baseBranch.type) {
                return .good
                
            } else {
                fail("Invalid base branch")
                return .rejected
            }
        }
        
    }
    
    // Check whether the PR contains merge commits or not
    func checkNoMergeCommitsIncluded(into result: inout CheckResult) {
        
        let doNoMergeCommitsCheckTitle = "Merge Commit Non-Existence Check"
        result.check(doNoMergeCommitsCheckTitle) {
            if commits.allSatisfy({ !$0.isMergeCommit }) {
                return .good
                
            } else {
                fail("Don't include any merge commits in this PR. Please consider rebasing if needed.")
                return .rejected

            }
        }
        
    }
    
    // Check whether the PR volume is less than a given number
    func checkDiffAmount(lessThan maxAmountOfModifiedLines: Int, into result: inout CheckResult) {
        
        let doDiffAmountCheckTitle = "Diff Volume Check"
        result.check(doDiffAmountCheckTitle) {
            if modifiedLines < maxAmountOfModifiedLines {
                return .good
                
            } else {
                warn("There's too much diff. Please make PRs smaller.")
                return .acceptable
            }
        }
        
    }
    
    // Check whether ChangeLog has been modified or not
    func checkChangeLogModification(at filePath: String, into result: inout CheckResult) {
        
        let doChangeLogModificationCheckTitle = "ChangeLog Modification Check"
        let hasChangeLogBeenModified = hasModifiedFile(at: filePath)
        
        result.check(doChangeLogModificationCheckTitle) {
            if hasChangeLogBeenModified {
                return .good
                
            } else {
                warn("This PR doesn't contain any modifications in \(filePath). Please consider to update the ChangeLog.")
                return .acceptable
            }
        }
        
    }
    
    // Check whether Version has been modified or not
    func checkVersionModification(at filePath: String, by keyword: String, into result: inout CheckResult) {
        
        let hasMarketingVersionBeenModified = hasModifiedContent(keyword, in: filePath)
        let doVersionModificationCheckTitle = "Version Modification Check"
        result.check(doVersionModificationCheckTitle) {
            if hasMarketingVersionBeenModified {
                warn("Please check whether the version modification is correct or not.")
                return .acceptable
                
            } else {
                fail("This PR doesn't contain any version modification, which is required.")
                return .rejected
            }
        }
        
        if hasMarketingVersionBeenModified {
            result.askReviewer(to: doVersionModificationCheckTitle)
        }
    }
    
    // Ask reviewers to check whether CI auto generated diff is valid or not
    func checkCIAutoPRModification(into result: inout CheckResult) {
        
        result.askReviewer(to: "Check whether CI's auto-generated PR is valid or not")
        warn("This PR is auto-generated by CI service. Please check if the diff is valid or not.")
        
    }
    
    // Ask reviewers to check whether all required tasks are closed
    func checkRemainedTasksState(into result: inout CheckResult) {
        
        result.askReviewer(to: "Remained Task Check")
        warn("Please check whether all required tickets and issues are closed or not.")
        
    }
}

// MARK: - Eda Methods for each workflow of PRs
extension Eda {
    
    func doCIServicePRCheck() -> CheckResult {
        
        var result = CheckResult(title: "CI Service PR Check")
        
        checkBaseBranch(expected: [.develop], into: &result)
        
        // CI auto-generated PRs should not contain any merge commits at first place.
        checkNoMergeCommitsIncluded(into: &result)
        
        checkCIAutoPRModification(into: &result)
        
        return result
        
    }
    
    func doFeaturePRCheck(configuration: GitFlowCheckConfiguration) -> CheckResult {
        
        var result = CheckResult(title: "Feature PR Check")
        
        checkBaseBranch(expected: [.develop], into: &result)
        
        if !configuration.acceptsMergeCommitsInFeaturePRs {
            checkNoMergeCommitsIncluded(into: &result)
        }
        
        checkDiffAmount(lessThan: configuration.recommendedMaxDiffAmountInFeaturePRs, into: &result)
        
        if case .yes(path: let filePath) = configuration.suggestsChangeLogUpdate {
            checkChangeLogModification(at: filePath, into: &result)
        }
        
        return result
        
    }
    
    func doReleasePRCheck(configuration: GitFlowCheckConfiguration) -> CheckResult {
        
        var result = CheckResult(title: "Release PR Check")
        
        // Release PRs should be merged both to main and develop branch
        checkBaseBranch(expected: [.main, .develop], into: &result)
        switch baseBranch?.type {
        case .main:
            result.askReviewer(to: "Please make sure you've also created another PR to develop branch")
            
        case .develop:
            result.askReviewer(to: "Please make sure you've also created another PR to main branch")
            
        default:
            break
        }
        
        if baseBranch?.type == .develop {
            // If it's merging to develop branch, there should be no merge commits in the PR
            checkNoMergeCommitsIncluded(into: &result)
            
            // If it's merging to develop branch, since there should be only version related modifications, diff volume should be less than 100 lines
            checkDiffAmount(lessThan: 100, into: &result)
        }
        
        checkRemainedTasksState(into: &result)
        
        if case .yes(let filePath, let keyword) = configuration.requiresVersionModificationInReleasePRs {
            checkVersionModification(at: filePath, by: keyword, into: &result)
        }
        
        return result
        
    }
    
    func doHotFixPRCheck(configuration: GitFlowCheckConfiguration) -> CheckResult {
        
        var result = CheckResult(title: "HotFix PR Check")
        
        // HotFix PRs should be merged both to main and develop branch
        checkBaseBranch(expected: [.main, .develop], into: &result)
        switch baseBranch?.type {
        case .main:
            result.askReviewer(to: "Please make sure you've also created another PR to develop branch")
            
        case .develop:
            result.askReviewer(to: "Please make sure you've also created another PR to main branch")
            
        default:
            break
        }
        
        // HotFix PRs should not contain any merge commits at first place.
        checkNoMergeCommitsIncluded(into: &result)
        
        checkDiffAmount(lessThan: configuration.recommendedMaxDiffAmountInFeaturePRs, into: &result)
        
        if case .yes(path: let filePath) = configuration.suggestsChangeLogUpdate {
            checkChangeLogModification(at: filePath, into: &result)
        }
        
        return result
        
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
        
        let checkResult = try { (type: Branch.BranchType) throws -> CheckResult in
            switch type {
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
        }(headBranch.type)
        
        shoki.report(checkResult)
        
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
