//
//  Detail.swift
//  lab3
//
//  Created by Hitarth Kakkad on 2022-12-01.
//

import UIKit
import CoreLocation

class Detail: UIViewController, CLLocationManagerDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forcastCell", for: indexPath)
        return cell
    }
    
    @IBOutlet var location: UILabel!
    @IBOutlet var temp: UILabel!
    @IBOutlet var condition: UILabel!
    @IBOutlet var high: UILabel!
    @IBOutlet var low: UILabel!
    @IBOutlet var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var loc = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeather(search: loc)
        location.text = loc
        tableView.dataSource = self
        print(getDayOfWeekString(today:"2022-12-03") ?? "")
        // Do any additional setup after loading the view.
    }
    func getDayOfWeekString(today:String)->String? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let todayDate = formatter.date(from: today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.weekday, from: todayDate)
            let weekDay = myComponents.weekday
            switch weekDay {
            case 1:
                return "Sun"
            case 2:
                return "Mon"
            case 3:
                return "Tue"
            case 4:
                return "Wed"
            case 5:
                return "Thu"
            case 6:
                return "Fri"
            case 7:
                return "Sat"
            default:
                print("Error fetching days")
                return "Day"
            }
        } else {
            return nil
        }
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
                    self.temp.text = "\(WeatherRes.current.temp_c)°"
                    self.condition.text = WeatherRes.current.condition.text
                    self.high.text = "H: \(WeatherRes.forecast.forecastday[0].day.maxtemp_c)°"
                    self.low.text = "L: \(WeatherRes.forecast.forecastday[0].day.mintemp_c)°"
                }
            }
        }
        dataTask.resume()
    }
   private func getURL(query: String) -> URL?{
       guard let url = "https://api.weatherapi.com/v1/forecast.json?key=ee31407e0be240f7b94130719221811&q=\(query)&days=8&aqi=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
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
        let forecast: Forecast
    }
    struct Forecast: Codable{
        let forecastday: [Forecastday]
    }
    struct Forecastday: Codable {
        let date: String
        let day: Day
    }
    struct Day: Codable{
        let maxtemp_c: Float
        let mintemp_c: Float
    }
    
    
    struct Location: Decodable{
        let name: String
        let region: String
        let lat: Double
        let lon: Double
    }
    struct Currunt: Decodable{
        let temp_c: Float
        let temp_f: Float
        let feelslike_c: Float
        let condition: Condition
    }
    struct Condition: Decodable{
        let text: String
        let code: Int
    }
    struct forcastList {
        let day: String
        let high: String
        let low: String
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}