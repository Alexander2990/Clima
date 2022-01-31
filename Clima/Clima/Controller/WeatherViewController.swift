//
//  ViewController.swift
//  Clima
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        
        weatherManager.delegate = self
        searchTextField.delegate = self
        
    }
    
    func didUpdateLocations() {
        
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
}


//MARK: - UITextFieldDelegate

// Расширение нашего класса WeatherViewController
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        // Закрывает клавиатуру iphone после нажатия кнопки
        searchTextField.endEditing(true)
        
    }
    
    // Возрат текста с поля searchTextField, при нажатии кнопки "go" на клавиатуре
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Закрывает клавиатуру iphone после нажатия кнопки "go"
        searchTextField.endEditing(true)
        return true
    }
    
    // Клавиатура не закрывается пока пользователь не введет в тектовое поле данные и не нажмет "go"
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    // Уведомляет наш View Controller, очистить тектовое поле, после нажатия кнопки "go"
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Перед сбросом текстового поля, код, который будет использовать данные введенные пользователем, т.е название города.
        
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatheManager: WeatherManager, weather: WeatherModel) {
        //        переводим процесс обновления UI (получение и отображение данных о погоде, в фоновый режим, чтобы не "заморозить" наше приложение
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
