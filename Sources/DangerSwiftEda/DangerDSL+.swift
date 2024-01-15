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
            prMetaDataResolver: { .init(
                gitHostingInstanceResolver: { Eda.gitHostingInstance ?? github },
                gitInstanceResolver: { git },
                hammerResolver: { hammer }
            )},
            prUtilityResolver: { .init(
                initialReportGenerator: shoki.makeInitialReport(title:),
                checkExecutor: shoki.check(_:into:execution:),
                todoExecutor: shoki.askReviewer(to:into:),
                messageExecutor: message(_:),
                warnExecutor: warn(_:),
                failExecutor: fail(_:)
            )},
            shokiResolver: { shoki }
        )
    }
    
}
