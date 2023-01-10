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
    
    // Customize for use
    public static var baseBranchNameResolver: ((Danger.GitHub) -> String)?
    public static var headBranchNameResolver: ((Danger.GitHub) -> String)?
    
    public static var additionLinesResolver: ((Danger.GitHub) -> Int)?
    public static var deletionLinesResolver: ((Danger.GitHub) -> Int)?
    public static var modifiedFilesResolver: ((Danger.Git) -> [String])?
    public static var commitsResolver: ((Danger.Git) -> [GitCommit])?
    
    init(
        gitHubInstanceResolver: @escaping () -> Danger.GitHub,
        gitInstanceResolver: @escaping () -> Danger.Git,
        hammerResolver: @escaping () -> Hammer
    ) {
        self.gitHubInstanceResolver = gitHubInstanceResolver
        self.gitInstanceResolver = gitInstanceResolver
        self.hammerResolver = hammerResolver
    }
    
}

// MARK: resolved properties
extension PRMetaData {
    
    public var baseBranchName: String {
        Self.baseBranchNameResolver?(gitHubInstanceResolver()) ?? gitHubInstanceResolver().pullRequest.base.ref
    }
    
    public var headBranchName: String {
        Self.headBranchNameResolver?(gitHubInstanceResolver()) ?? gitHubInstanceResolver().pullRequest.head.ref
    }
    
    public var additionLines: Int {
        Self.additionLinesResolver?(gitHubInstanceResolver()) ?? gitHubInstanceResolver().pullRequest.additions ?? 0
    }
    
    public var deletionLines: Int {
        Self.deletionLinesResolver?(gitHubInstanceResolver()) ?? gitHubInstanceResolver().pullRequest.deletions ?? 0
    }
    
    public var modifiedLines: Int {
        additionLines + deletionLines
    }
    
    public var modifiedFiles: [String] {
        Self.modifiedFilesResolver?(gitInstanceResolver()) ?? gitInstanceResolver().modifiedFiles
    }
    
    public func hasModifiedFile(at filePath: String) -> Bool {
        modifiedFiles.contains(filePath)
    }
    
    public func hasModifiedContent(_ content: String, at filePath: String) -> Bool {
        hammerResolver().diffLines(in: filePath).additions.contains(where: { $0.contains(content) })
    }
    
    public var commits: [GitCommit] {
        Self.commitsResolver?(gitInstanceResolver()) ?? gitInstanceResolver().commits
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
