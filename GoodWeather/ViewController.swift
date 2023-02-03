//
//  ViewController.swift
//  GoodWeather
//
//  Created by Myo Thura Zaw on 01/02/2023.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

	@IBOutlet weak var cityNameTextField: UITextField!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	
	let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
			.asObservable()
			.map({ self.cityNameTextField.text })
			.subscribe(onNext: { city in
				if let city = city {
					if city.isEmpty {
						self.displayWeather(nil)
					} else {
						self.fetchWeather(by: city)
					}
				}
			})
			.disposed(by: disposeBag)
		
//		self.cityNameTextField.rx.value
//			.subscribe(onNext: { city in
//				if let city = city {
//					if city.isEmpty {
//						self.displayWeather(nil)
//					} else {
//						self.fetchWeather(by: city)
//					}
//				}
//			}).disposed(by: disposeBag)
	}
	
	private func displayWeather(_ weather: Weather?) {
		if let weather = weather {
			self.temperatureLabel.text = "\(weather.temp) ℉"
			self.humidityLabel.text = "\(weather.humidity) 💧"
		} else {
			self.temperatureLabel.text = "No Temp"
			self.humidityLabel.text = "No Humidity"
		}
	}
	
	private func fetchWeather(by city: String) {
		guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
			  let url = URL.urlForWeatherAPI(city: cityEncoded) else {
				  return
			  }
		let resource = Resource<WeatherResult>(url: url)
		
		// MARK: - Not binding to control properties, assigning typical UI controls
//		URLRequest.load(resource: resource)
//			.observe(on: MainScheduler.instance)
//			.catchAndReturn(WeatherResult.empty)
//			.subscribe(onNext: { result in
//				let weather = result.main
//				self.displayWeather(weather)
//			})
//			.disposed(by: disposeBag)
		
		// MARK: - By using Control Properties
//		let search = URLRequest.load(resource: resource)
//			.observe(on: MainScheduler.instance)
//			.catchAndReturn(WeatherResult.empty)
//
//		search.map({ "\($0.main.temp) ℉" })
//			.bind(to: self.temperatureLabel.rx.text)
//			.disposed(by: disposeBag)
//
//		search.map({ "\($0.main.humidity) 💧" })
//			.bind(to: self.humidityLabel.rx.text)
//			.disposed(by: disposeBag)
		
		
		// MARK: - By using drivers
//		let search = URLRequest.load(resource: resource)
//			.asDriver(onErrorJustReturn: WeatherResult.empty)
		
		let search = URLRequest.load(resource: resource)
			.observe(on: MainScheduler.instance)
			.retry(3)
			.catch { error in
				print(error.localizedDescription)
				return Observable.just(WeatherResult.empty)
			}
			.asDriver(onErrorJustReturn: WeatherResult.empty)
		
		search.map({ "\($0.main.temp) ℉" })
			.drive(self.temperatureLabel.rx.text)
			.disposed(by: disposeBag)
		
		search.map({ "\($0.main.humidity) 💧" })
			.drive(self.humidityLabel.rx.text)
			.disposed(by: disposeBag)
				
	}

}

// MARK: - Control Properties
// self.temperatureLabel.rx.text

// MARK: - Control Events
// self.cityNameTextField.rx.controlEvent(.editingDidEndOnExit)

// MARK: - Drivers
// Units can't error out
// Units are observed on main scheduler
// Units subscribe on main scheduler
// Units share side effects


