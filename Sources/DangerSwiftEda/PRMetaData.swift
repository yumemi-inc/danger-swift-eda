//
//  PRMetaData.swift
//  
//
//  Created by 史 翔新 on 2022/10/27.
//

import Foundation
import Danger
import DangerSwiftHammer

// MARK: - PR Info

// MARK: resolvers
public struct PRMetaData {
    
    private let gitHubInstanceResolver: () -> Danger.GitHub
    private let gitInstanceResolver: () -> Danger.Git
    private let hammerResolver: () -> Hammer
    
    // Custom resolvers only used for testing as a mock
    private let baseBranchNameResolver: (() -> String)?
    private let headBranchNameResolver: (() -> String)?
    
    private let additionLinesResolver: (() -> Int)?
    private let deletionLinesResolver: (() -> Int)?
    private let modifiedFilesResolver: (() -> [String])?
    private let commitsResolver: (() -> [GitCommit])?
    
    init(
        gitHubInstanceResolver: @escaping () -> Danger.GitHub,
        gitInstanceResolver: @escaping () -> Danger.Git,
        hammerResolver: @escaping () -> Hammer,
        baseBranchNameResolver: (() -> String)? = nil,
        headBranchNameResolver: (() -> String)? = nil,
        additionLinesResolver: (() -> Int)? = nil,
        deletionLinesResolver: (() -> Int)? = nil,
        modifiedFilesResolver: (() -> [String])? = nil,
        commitsResolver: (() -> [GitCommit])? = nil
    ) {
        self.gitHubInstanceResolver = gitHubInstanceResolver
        self.gitInstanceResolver = gitInstanceResolver
        self.hammerResolver = hammerResolver
        self.baseBranchNameResolver = baseBranchNameResolver
        self.headBranchNameResolver = headBranchNameResolver
        self.additionLinesResolver = additionLinesResolver
        self.deletionLinesResolver = deletionLinesResolver
        self.modifiedFilesResolver = modifiedFilesResolver
        self.commitsResolver = commitsResolver
    }
    
}

// MARK: resolved properties
extension PRMetaData {
    
    public var baseBranchName: String {
        baseBranchNameResolver?() ?? gitHubInstanceResolver().pullRequest.base.ref
    }
    
    public var headBranchName: String {
        headBranchNameResolver?() ?? gitHubInstanceResolver().pullRequest.head.ref
    }
    
    public var additionLines: Int {
        additionLinesResolver?() ?? gitHubInstanceResolver().pullRequest.additions ?? 0
    }
    
    public var deletionLines: Int {
        deletionLinesResolver?() ?? gitHubInstanceResolver().pullRequest.deletions ?? 0
    }
    
    public var modifiedLines: Int {
        additionLines + deletionLines
    }
    
    public var modifiedFiles: [String] {
        modifiedFilesResolver?() ?? gitInstanceResolver().modifiedFiles
    }
    
    public func hasModifiedFile(at filePath: String) -> Bool {
        modifiedFiles.contains(filePath)
    }
    
    public func hasModifiedContent(_ content: String, at filePath: String) -> Bool {
        hammerResolver().diffLines(in: filePath).additions.contains(where: { $0.contains(content) })
    }
    
    public var commits: [GitCommit] {
        commitsResolver?() ?? gitInstanceResolver().commits
    }
    
    public func diffLines(in filePath: String) -> (deletions: [String], additions: [String]) {
        hammerResolver().diffLines(in: filePath)
    }
    
    public var customGitHubInstance: Danger.GitHub {
        gitHubInstanceResolver()
    }
    
    public var customGitInstance: Danger.Git {
        gitInstanceResolver()
    }
    
}
