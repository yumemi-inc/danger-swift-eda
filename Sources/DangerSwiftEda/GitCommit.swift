//
//  File.swift
//  
//
//  Created by 史 翔新 on 2021/11/16.
//

import Danger

extension Git.Commit {
    
    var isMergeCommit: Bool {
        
        guard let parents = parents else {
            return false
        }
        
        return parents.count > 1
        
    }
    
}
