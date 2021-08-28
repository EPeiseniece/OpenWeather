//
//  ViewController.swift
//  OpenWeather
//
//  Created by elina.peiseniece on 28/08/2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
 
    

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
   let weatherDataModle = WeatherDataModel()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
//MARK: -CLLocationManager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            print("Long: \(location.coordinate.longitude), lat: \(location.coordinate.latitude)")
            
            let lat = String(location.coordinate.latitude)
            let long = String(location.coordinate.longitude)
            
            let params: [String:String] = ["lat": lat, "lon": long, "appid": weatherDataModle.apiId]
            getWeatherData(url: weatherDataModle.apiUrl, params: params)
        }
    }

    func getWeatherData(url: String, params: [String:String]){
        AF.request(url, method: .get, parameters: params).responseJSON {response in
            if response.value != nil{
                let weatherJSON: JSON = JSON(response.value!)
                print("weatherJSON ", weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }else{
                self.cityLabel.text = "Weather unavailable 🥲 "
            }
            
        }
    }
    
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double{
            weatherDataModle.temp = Int(tempResult - 273.15)
            weatherDataModle.city = json["name"].stringValue
            weatherDataModle.condition = json["weather"][0]["id"].intValue
            weatherDataModle.weatherIconName = weatherDataModle.updateWeatherIcon(condition: weatherDataModle.condition)
            
            updateUI()
        }else{
            self.cityLabel.text = "Weather unavailable 🥲 "
        }
    }
    
    func updateUI(){
        cityLabel.text = weatherDataModle.city
        tempLabel.text = "\(weatherDataModle.temp)ºC"
        weatherIcon.image = UIImage(named: weatherDataModle.weatherIconName)
        
    }
    func userEnterCityName(city: String) {
        print(city)
        let params: [String: String] = ["q": city,"appid": weatherDataModle.apiId]
        getWeatherData(url: weatherDataModle.apiUrl, params: params)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "city"{
            let vc = segue.destination as! ChangeCityViewController
            vc.delegate = self
        }
    }
    
}

