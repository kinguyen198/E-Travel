//
//  CurrentWeather.swift
//  e-Travel
//
//  Created by Kii Nguyen on 2/23/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import Foundation
class CurrentWeather{
    let temperature: Int?
    let humidity: Int?
    let precipProbability: Int?
    let sumary:String?
    let icon:String?

    struct WeatherKeys {
        static let temperature = "temperature"
        static let humidity = "humidity"
        static let precipProbability = "precipProbability"
        static let sumary = "sumary"
        static let icon = "icon"
    }

    init(weatherDictionary:[String: Any]) {
        if let temperatureDouble = weatherDictionary[WeatherKeys.temperature] as? Double {
            temperature = Int(temperatureDouble )
        }else{

            temperature = nil
        }

        if let humidityDouble = weatherDictionary[WeatherKeys.humidity] as? Double{
            humidity = Int(humidityDouble * 100)
        }else{
            humidity = nil
        }

        if let precipDouble = weatherDictionary[WeatherKeys.precipProbability] as? Double{
            precipProbability = Int(precipDouble*100)
        }else{
            precipProbability = nil
        }
        sumary = weatherDictionary[WeatherKeys.sumary] as? String
        icon = weatherDictionary[WeatherKeys.icon] as? String
    }
}

