//
//  ViewController.swift
//  lab3
//
//  Created by Hitarth Kakkad on 2022-11-17.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var lat = 0.0
    var long = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    func setupMap() {
        let location = CLLocation(latitude: lat, longitude: long)
        let radiusInMeters: CLLocationDistance = 50000
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        mapView.setRegion(region, animated: true)
        print(lat,long)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: searchTextField.text)
        return true
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
    }
    
    @IBAction func curruntLocation(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
        guard let url = getURL(query: search) else {
            print("Unable to get URL")
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) {data, respose, error in
            print("Network Call is completed")
            guard error == nil else {
                print("error")
                return
            }
            guard let data = data else {
                print("No data found")
                return
            }
            if let WeatherRes = self.parseJson(data: data){
                print(WeatherRes.location.name)
                print(WeatherRes.current.temp_c)
                DispatchQueue.main.async {
                    self.lat = WeatherRes.location.lat
                    self.long = WeatherRes.location.lon
                    self.setupMap()
                }
            }
        }
        dataTask.resume()
    }
   private func getURL(query: String) -> URL?{
       guard let url = "https://api.weatherapi.com/v1/current.json?key=ee31407e0be240f7b94130719221811&q=\(query)&aqi=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
           return nil
       }
        return URL(string: url)
    }
    private func parseJson(data: Data) -> weatherResponse? {
        let decoder = JSONDecoder()
        var weather: weatherResponse?
        do{
            weather = try decoder.decode(weatherResponse.self, from: data)
        }catch{
            print("Error Decoding")
        }
        return weather
    }
    struct weatherResponse: Decodable{
        let location: Location
        let current: Currunt
    }
    struct Location: Decodable{
        let name: String
        let lat: Double
        let lon: Double
    }
    struct Currunt: Decodable{
        let temp_c: Float
        let temp_f: Float
        let condition: Condition
    }
    struct Condition: Decodable{
        let text: String
        let code: Int
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            loadWeather(search: coordinates)
            setupMap()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
