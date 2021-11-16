//
//  DangerDSL+.swift
//  
//
//  Created by 史 翔新 on 2021/11/13.
//

import Danger

extension DangerDSL {
    
    public var eda: Eda {
        .init(
            headBranchResolver: { .parsed(from: github.pullRequest.head.ref) },
            baseBranchResolver: { .parsed(from: github.pullRequest.base.ref) },
            additionLinesResolver: { github.pullRequest.additions ?? 0 },
            deletionLinesResolver: { github.pullRequest.deletions ?? 0 },
            modifiedFilesResolver: { git.modifiedFiles },
            commitsResolver: { git.commits },
            hammerResolver: { hammer },
            messageExecutor: { message($0) },
            warnExecutor: { warn($0) },
            failExecutor: { fail($0) },
            reportExecutor: { shoki.report($0) })
    }
    
}
