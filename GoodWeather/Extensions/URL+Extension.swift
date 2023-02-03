//
//  URL+Extension.swift
//  GoodWeather
//
//  Created by Myo Thura Zaw on 02/02/2023.
//

import Foundation

extension URL {
	static func urlForWeatherAPI(city: String) -> URL? {
		return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=28d5b0c8a61576a93ca4fcd16182ce06&units=imperial")
	}
}
