//
//  GitHostingInstance.swift
//  
//
//  Created by 古宮 伸久 on 2024/01/12.
//

import Danger

public protocol GitHostingInstance {
    var baseBranchName: String { get }
    var headBranchName: String { get }
    var additionLines: Int? { get }
    var deletionLines: Int? { get }
}

extension Danger.GitHub: GitHostingInstance {
    public var baseBranchName: String {
        pullRequest.base.ref
    }

    public var headBranchName: String {
        pullRequest.head.ref
    }

    public var additionLines: Int? {
        pullRequest.additions
    }

    public var deletionLines: Int? {
        pullRequest.deletions
    }
}

extension Danger.GitLab: GitHostingInstance {
    public var baseBranchName: String {
        mergeRequest.sourceBranch.name
    }

    public var headBranchName: String {
        mergeRequest.targetBranch.name
    }

    public var additionLines: Int? {
        Int(mergeRequest.changesCount.replacingOccurrences(of: "+", with: ""))
    }

    public var deletionLines: Int? {
        nil
    }
}

extension Danger.BitBucketCloud: GitHostingInstance {
    public var baseBranchName: String {
        pr.source.branchName
    }

    public var headBranchName: String {
        pr.destination.branchName
    }

    public var additionLines: Int? {
        nil
    }

    public var deletionLines: Int? {
        nil
    }
}

extension Danger.BitBucketServer: GitHostingInstance {
    public var baseBranchName: String {
        pullRequest.fromRef.id
    }

    public var headBranchName: String {
        pullRequest.toRef.id
    }

    public var additionLines: Int? {
        nil
    }

    public var deletionLines: Int? {
        nil
    }
}
