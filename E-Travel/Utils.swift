//
//  Utils.swift
//
//  Created by iMac1 on 9/24/18.
//  Copyright © 2018 AboutDTU. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

struct Utils {
    //Kiểm tra kết nối mạng
    public static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }

    //Chuyển kiểu hashmap sang chuỗi json
    public static func hashMapToJson(any: Any) -> String{

        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: any,
            options: []) {
            guard let json = String(data: theJSONData, encoding: .utf8)else{
                return ""
            }
            return json

        }
        return ""
    }

    //Chuyển chuỗi null sang nil
    public static func nullToNil(value: AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        }else {
            return value
        }
    }

    public static func animate(_ sender: UITableView){
        UIView.animate(withDuration: 0.3) {
            sender.isHidden = !sender.isHidden
        }
    }

    public static func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }

}

