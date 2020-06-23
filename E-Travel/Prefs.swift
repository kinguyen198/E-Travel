//
//  Prefs.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/9/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
class Prefs {

    private static let PREFERENCE_TOKEN = "PREFERENCE_TOKEN"
    private static let PREFERENCE_FCM_TOKEN = "PREFERENCE_FCM_TOKEN"

    public static let prefs = Prefs()

    private func set(key: String, value: Any?){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    private func get(key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }

    
    func setValue(key: String, value: Any){
        set(key: key, value: value)
    }

    func getValue(key: String) -> Any?{
        let value = get(key: key)
        return value
    }
}
