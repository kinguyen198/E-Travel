//
//  DebugLog.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/9/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
struct DebugLog {
    public static func printLog(msg: String){
        if Constants.IS_DEBUG {
            print(msg)
        }
    }
}
