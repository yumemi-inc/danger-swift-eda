//
//  String+.swift
//  
//
//  Created by 史 翔新 on 2021/11/11.
//

import Foundation

extension String {
    
    private enum RegexError: Error {
        case positionalCaptureGroupFailureInRegexPattern(pattern: String)
    }
    
    func substring(ofPattern string: String) -> String? {
        
        // In order to extract text like `(\d+)` we still need `NSRegularExpression` and `NSRange`…
        // Ref: https://nshipster.com/swift-regular-expressions/#enumerating-matches-with-positional-capture-groups
        do {
            let regex = try NSRegularExpression(pattern: string, options: [])
            let nsSelf = self as NSString
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsSelf.length))
            guard let match = matches.first else {
                return nil
            }
            
            guard match.numberOfRanges == 2 else {
                throw RegexError.positionalCaptureGroupFailureInRegexPattern(pattern: string)
            }
            let range = match.range(at: 1)
            let substring = nsSelf.substring(with: range)
            
            return substring
            
        } catch {
            assertionFailure("\(error)")
            return nil
        }
        
    }
    
    func contains(pattern: String) -> Bool {
        
       return range(of: pattern, options: .regularExpression) != nil
        
    }
    
}

extension String {
    
    @available(macOS 13, *)
    func matches<R: RegexComponent>(_ pattern: R) -> Bool {
        
        wholeMatch(of: pattern) != nil
        
    }
    
}
