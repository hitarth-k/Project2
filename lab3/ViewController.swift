//
//  ViewController.swift
//  lab3
//
//  Created by Hitarth Kakkad on 2022-11-17.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var lat = 0.0
    var long = 0.0
    var weatherCondition = ""
    var desc = ""
    var temp: Float = 0
    var list: [weatherList] = []
    var loc = ""
    var code = 0
    private var path: String = "MyWeatherList.plist"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadItem()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        addAnnotation(location: CLLocation(latitude: lat, longitude: long))
        tableView.dataSource = self
        tableView.delegate = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
        let item = list[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryText = item.subtitle
        content.image = UIImage(systemName: item.code)
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.load(search: "\(self.list[indexPath.row].title),\(self.list[indexPath.row].subtitle)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func saveList(item: weatherList){
        let userDocuments = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let weatherListPath = userDocuments.first?.appendingPathComponent(path) else {
            return
        }
        list.append(item)
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(list)
            try data.write(to: weatherListPath)
        }
        catch{
            print(error)
        }

        self.tableView.reloadData()
    }
    
    private func loadItem(){
        let userDocuments = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let weatherListPath = userDocuments.first?.appendingPathComponent(path) else {
            return
        }
        let decoder = PropertyListDecoder()
        do{
            let data = try Data(contentsOf: weatherListPath)
            let decodedData = try decoder.decode([weatherList].self, from: data)
            list = decodedData
            tableView.reloadData()
        }catch{
            print(error)
        }
    }

    func addImage(code: Int)->String{
        switch code {
        case 1066:
            return  "snowflake.circle.fill"
        case 1014:
            return "snowflake.circle.fill"
        case 1213:
            return "snowflake.circle.fill"
        case 1210:
            return "snowflake.circle.fill"
        case 1216:
            return "snowflake.circle.fill"
        case 1219:
            return "snowflake.circle.fill"
        case 1225:
            return "snowflake.circle.fill"
        case 1000:
            return  "sun.max.circle.fill"
        case 1192:
            return "cloud.rain.fill"
        case 1195:
            return "cloud.rain.fill"
        case 1198:
            return "cloud.rain.fill"
        case 1201:
            return "cloud.rain.fill"
        case 1240:
            return "cloud.rain.fill"
        case 1243:
            return "cloud.rain.fill"
        case 1183:
            return "cloud.rain.fill"
        case 1003:
            return  "cloud.circle"
        case 1006:
            return "cloud.circle"
        case 1009:
            return "cloud.circle"
        case 1135:
            return  "cloud.fog.fill"
            
        default:
            return "cloud.sun.rain.fill"
        }
    }
    
    func setupMap() {
        mapView.delegate = self
        let location = CLLocation(latitude: lat, longitude: long)
        let radiusInMeters: CLLocationDistance = 10000
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        mapView.setRegion(region, animated: true)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 50000)
        mapView.setCameraZoomRange(zoomRange ,animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "WIT"
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: 0.0, y: 10.0)
        let button = UIButton(type: .detailDisclosure)
        button.tag = 10
        view.rightCalloutAccessoryView = button
        view.leftCalloutAccessoryView = UIImageView(image: UIImage(systemName: addImage(code: code)) )
        view.glyphText = "\(temp)"
        if(temp < 0){
            view.markerTintColor = UIColor.purple
        }
        else if(temp >= 0 && temp <= 11){
            view.markerTintColor = UIColor.blue
        }
        else if(temp > 11 && temp <= 16 ){
            view.markerTintColor = UIColor.systemBlue
        }
        else if(temp > 16 && temp <= 24 ){
            view.markerTintColor = UIColor.orange
        }
        else if(temp > 24 && temp <= 30 ){
            view.markerTintColor = UIColor.systemRed
        }
        else if(temp > 34){
            view.markerTintColor = UIColor.red
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
       //Open Detais screen (use the psudo code from notes)
        if(control.tag == 10){
            performSegue(withIdentifier: "goToDetail", sender: self)
        }
        else{
            return
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            guard let vc = segue.destination as? Detail else {return}
            vc.loc = loc
        }
    }
    
    func addAnnotation(location: CLLocation){
        let annotation = MyAnnotation(coordinate: location.coordinate, title: weatherCondition, subtitle: desc )
        mapView.addAnnotation(annotation)
    }
    func load(search: String?){
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
                    self.loc = "\(WeatherRes.location.name),\(WeatherRes.location.region)"
                    self.temp = WeatherRes.current.temp_c
                    self.lat = WeatherRes.location.lat
                    self.long = WeatherRes.location.lon
                    self.code = WeatherRes.current.condition.code
                    self.weatherCondition = WeatherRes.current.condition.text
                    self.desc = "Tempreture :: \(WeatherRes.current.temp_c)??C  Feels like :: \(WeatherRes.current.feelslike_c)??C"
                    self.setupMap()
                    self.addAnnotation(location: CLLocation(latitude: WeatherRes.location.lat, longitude: WeatherRes.location.lon))
                }
            }
        }
        dataTask.resume()
    }
    func loadWeather(search: String?){
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
                    self.loc = "\(WeatherRes.location.name),\(WeatherRes.location.region)"
                    self.temp = WeatherRes.current.temp_c
                    self.lat = WeatherRes.location.lat
                    self.long = WeatherRes.location.lon
                    self.weatherCondition = WeatherRes.current.condition.text
                    self.desc = "Tempreture :: \(WeatherRes.current.temp_c)??C  Feels like :: \(WeatherRes.current.feelslike_c)??C"
                    self.code = WeatherRes.current.condition.code
                    self.setupMap()
                    self.addAnnotation(location: CLLocation(latitude: WeatherRes.location.lat, longitude: WeatherRes.location.lon))
                    let item = weatherList(title: "\(WeatherRes.location.name), \(WeatherRes.location.region)", subtitle: "Currunt:: \(WeatherRes.current.temp_c)(H:: \(WeatherRes.forecast.forecastday[0].day.maxtemp_c), L: \(WeatherRes.forecast.forecastday[0].day.mintemp_c))", code: self.addImage(code: WeatherRes.current.condition.code))
                    if (WeatherRes.location.name != ""){
                        self.saveList(item: item)
                    }
                }
            }
        }
        dataTask.resume()
    }
   private func getURL(query: String) -> URL?{
       guard let url = "https://api.weatherapi.com/v1/forecast.json?key=fd155cb758c542dcbf923615221612&q=\(query)&days=7&aqi=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
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
    struct weatherList: Codable{
        let title: String
        let subtitle: String
        let code: String
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            load(search: coordinates)
            setupMap()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    class MyAnnotation: NSObject,MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        var image: UIImage?
        init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
            self.image = UIImage(systemName: "cloud.sun.rain.fill")!
            super.init()
        }
    }
}
