//
//  DownloadAsyncTask.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/9/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON
import SwiftOverlays
class DownloadAsyncTask{
    public static func POST(url: String, body: [String: Any], showDialog: Bool, downloadCalback: @escaping (_ errorCode: Int, _ message: String, _ data: String?) -> Void){
        if Utils.isConnectedToNetwork() == false {/*Rớt mạng*/
            DispatchQueue.main.async {
                downloadCalback(Constants.ERROR_CODE_ERROR, "Sorry, no Internet connectivity detected. Please reconnect and try again.", nil)
            }
            SwiftOverlays.removeAllBlockingOverlays()
        }else{
            let session = URLSession.shared
            var token: String = "bearer "
            //if let tokenModel = Prefs.prefs.getToken() {
                //token = token + "\(tokenModel.access_token)"
            //}
            let headers = [
                "content-type": "application/json",
                "authorization": token,
                "cache-control": "no-cache",
                "postman-token": "f05da2d1-ffe9-895f-baf0-8dfb3a5b0fcb"
            ]
            if url.isEmpty { /*Truyền tham số sai*/
                DebugLog.printLog(msg: Constants.DOWNLOAD_ERROR+":Đường dẫn (URL) truyền vào rỗng.")
                SwiftOverlays.removeAllBlockingOverlays()
                return
            }

            let postData = try? JSONSerialization.data(withJSONObject: body, options: [])


            let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)

            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData

            if showDialog {
                // SwiftOverlays.showBlockingWaitOverlayWithText(LocalizationHelper.shared.localized("Loading...")!)
                SwiftOverlays.showBlockingWaitOverlayWithText("Loading...")
            }
            DebugLog.printLog(msg: "URL_REQUEST: "+url)

            let task = session.dataTask(with: request as URLRequest) {
                (data, response, error) in
                DispatchQueue.main.async {
                    SwiftOverlays.removeAllBlockingOverlays()
                }
                if error != nil {/*Lỗi trong quá trình tải*/
                    DebugLog.printLog(msg: "DOWNLOAD_ERROR: Lỗi trong quá trình tải, tên lỗi: "+error!.localizedDescription)
                    DispatchQueue.main.async {
                        downloadCalback(Constants.ERROR_CODE_ERROR, error!.localizedDescription, nil)
                    }
                }else{
                    /*Dữ liệu trả về rỗng*/
                    guard let data = data else{
                        DebugLog.printLog(msg: Constants.DOWNLOAD_ERROR+": Dữ liệu trả về rỗng.")
                        DispatchQueue.main.async {
                            downloadCalback(Constants.ERROR_CODE_ERROR, "Sorry an error has occurred.", nil)
                        }
                        return
                    }

                    do{
                        let jsonEncode = String(data: data, encoding: .utf8)
                        let dataEncode = jsonEncode?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        DebugLog.printLog(msg: Constants.DOWNLOAD_RESPONSE+": "+jsonEncode!)

                        //Chưa có
                        //                        if let messageResponse = MessageResponse.deserialize(from: jsonEncode) {
                        //                            if messageResponse.Message != "" {
                        //                                DispatchQueue.main.async {
                        //                                    Prefs.prefs.setUser(user: "")
                        //                                    Prefs.prefs.setNumberNotificationUnread(number: 0)
                        //                                    UIApplication.shared.applicationIconBadgeNumber = 0
                        //                                    Prefs.prefs.setCurrentConference(conference: "")
                        //                                    downloadCalback(Constants.ERROR_CODE_ERROR, messageResponse.Message, jsonEncode)
                        //                                }
                        //                            }
                        //                            return
                        //                        }

                        if dataEncode == nil || jsonEncode == nil{/*Lỗi trong quá trình encode*/
                            DebugLog.printLog(msg: Constants.DOWNLOAD_ERROR+": Lỗi trong quá trình encode.")
                            DispatchQueue.main.async {
                                downloadCalback(Constants.ERROR_CODE_ERROR, "Sorry an error has occurred.", nil)
                            }
                        }else{
                            let json = try? JSONSerialization.jsonObject(with: dataEncode!, options: []) as! [String: AnyObject]

                            guard let errorCode = json?["errorCode"] as? Int else {
                                DebugLog.printLog(msg: Constants.DOWNLOAD_ERROR+": Chuỗi json không có errorCode.")
                                DispatchQueue.main.async {
                                    downloadCalback(Constants.ERROR_CODE_ERROR, "Sorry an error has occurred.", jsonEncode)
                                }
                                return
                            }
                            guard let message = json?["message"] as? String else {
                                DebugLog.printLog(msg: Constants.DOWNLOAD_ERROR+": Chuỗi json không có message.")
                                DispatchQueue.main.async {
                                    downloadCalback(Constants.ERROR_CODE_ERROR, "Sorry an error has occurred.", jsonEncode)
                                }
                                return
                            }
                            guard let data = json?["data"] else {/*Chuỗi json trả về không có data */
                                DispatchQueue.main.async {
                                    downloadCalback(errorCode, message, nil)
                                }
                                return
                            }

                            if Utils.nullToNil(value: data) == nil {/*"data" trả về là null*/
                                DispatchQueue.main.async {
                                    downloadCalback(errorCode, message, nil)
                                }
                                return
                            }

                            DispatchQueue.main.async {
                                downloadCalback(errorCode, message, Utils.hashMapToJson(any: data))
                            }
                        }
                    }

                }
            }
            task.resume()

        }
    }
}

