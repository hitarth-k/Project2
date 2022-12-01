//
//  ViewController.swift
//  lab3
//
//  Created by Hitarth Kakkad on 2022-11-17.
//

import UIKit
import CoreLocation

class AddList: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet var temp: UILabel!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var locationLable: UILabel!
    @IBOutlet var changer: UISegmentedControl!
    @IBOutlet var image: UIImageView!
    @IBOutlet var condition: UILabel!
    var celcius = ""
    var faren = ""
    let locationManager = CLLocationManager()
    var long = ""
    var lat = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.delegate = self
        locationManager.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: searchTextField.text)
        return true
    }

    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0){
            temp.text = celcius
        }
        else{
            temp.text = faren
        }
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
    }
    
    @IBAction func curruntLocation(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        print(lat , long)
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
                    let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .white])
                    self.image.preferredSymbolConfiguration = config
                    self.celcius = "\(WeatherRes.current.temp_c)°C"
                    self.faren = "\(WeatherRes.current.temp_f)°F"
                    self.locationLable.text = WeatherRes.location.name
                    self.condition.text = WeatherRes.current.condition.text
                    if (self.changer.selectedSegmentIndex == 0){
                        self.temp.text = "\(WeatherRes.current.temp_c)°C"
                    }
                    else if (self.changer.selectedSegmentIndex == 1){
                        self.temp.text = "\(WeatherRes.current.temp_f)°F"
                    }
                    else{
                        self.temp.text = "\(WeatherRes.current.temp_c)°C"
                    }
                    if(WeatherRes.current.condition.code == 1000){
                        self.image.image = UIImage(systemName: "sun.max.circle.fill")
                    }
                    else if(WeatherRes.current.condition.code == 1066 || WeatherRes.current.condition.code == 1114 || WeatherRes.current.condition.code == 1213 || WeatherRes.current.condition.code == 1210 || WeatherRes.current.condition.code == 1216 || WeatherRes.current.condition.code == 1219 || WeatherRes.current.condition.code == 1225){
                        self.image.image = UIImage(systemName: "snowflake.circle.fill")
                    }
                    else if(WeatherRes.current.condition.code == 1192 || WeatherRes.current.condition.code == 1195 || WeatherRes.current.condition.code == 1198 || WeatherRes.current.condition.code == 1201 || WeatherRes.current.condition.code == 1240 || WeatherRes.current.condition.code == 1243 || WeatherRes.current.condition.code == 1183 ){
                        self.image.image = UIImage(systemName: "cloud.rain.fill")
                    }
                    else if(WeatherRes.current.condition.code == 1003 || WeatherRes.current.condition.code == 1006){
                        self.image.image = UIImage(systemName: "cloud.circle")
                    }
                    else{
                        self.image.image = UIImage(systemName: "cloud.sun.rain.fill")
                    }
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
            self.long = "\(location.coordinate.longitude)"
            self.lat = "\(location.coordinate.latitude)"
            loadWeather(search: coordinates)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
