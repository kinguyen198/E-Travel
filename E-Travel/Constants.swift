//
//  Constants.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/9/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import UIKit
struct Constants {

    public static let IS_DEBUG: Bool = true
    /*Error code*/
    public static let ERROR_CODE = "errorCode"
    public static let MESSAGE = "message"
    public static let DOWNLOAD_ERROR = "DOWNLOAD_ERROR"
    public static let DOWNLOAD_RESPONSE = "DOWNLOAD_RESPONSE"

    /*Error code*/
    public static let ERROR_CODE_SUCCESS = 0
    public static let ERROR_CODE_ERROR = 1

    private static let URL_SERVER: String = "https://o4mande4nk.execute-api.ap-southeast-1.amazonaws.com/dev/auth/"
    public static let API_POST_LOGIN = URL_SERVER + "login"
    public static let API_POST_REGISTER = URL_SERVER + "register"
}
