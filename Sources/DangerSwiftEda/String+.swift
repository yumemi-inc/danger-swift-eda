//
//  String+.swift
//  
//
//  Created by 史 翔新 on 2021/11/11.
//

import Foundation

extension String {
    
    func matches<R: RegexComponent>(_ pattern: R) -> Bool {
        
        wholeMatch(of: pattern) != nil
        
    }
    
}
