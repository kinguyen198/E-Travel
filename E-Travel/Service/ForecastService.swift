//
//  ForecastService.swift
//  e-Travel
//
//  Created by Kii Nguyen on 2/23/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftOverlays
class ForecastService
{
    let forecastAPIKey: String
    let forecastBaseURL: URL?
    init(APIKey: String) {
        self.forecastAPIKey=APIKey
        forecastBaseURL=URL(string: "https://api.darksky.net/forecast/\(APIKey)")
    }

    func getCurrentWeather(latitude: Double, longtitude:Double, completion: @escaping(CurrentWeather?)->Void) 
    {
//        DispatchQueue.main.async {
//            showSw
//        }
        if let forecastURL = URL(string:"\(forecastBaseURL!)/\(latitude),\(longtitude)"){
            Alamofire.request(forecastURL).responseJSON(completionHandler: {(response) in
                if let jsonDictionary = response.result.value as? [String :Any]{
                    if let currentWeatherDictionary = jsonDictionary["currently"] as? [String: Any] {
                        let currentWeather = CurrentWeather(weatherDictionary: currentWeatherDictionary)
                        completion(currentWeather)
                    }else{
                        completion(nil)
                    }
                }

            })
        }
    }
}
