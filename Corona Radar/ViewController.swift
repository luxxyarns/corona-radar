 
 import Foundation
 import UIKit
 import MapKit
 import CoreLocation
 import SwiftCSV
 
 class ViewController : UIViewController , CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var reloadImage: UIImageView!
    private var userTrackingButton: MKUserTrackingButton!
    private var scaleView: MKScaleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navcon = self.navigationController {
            let navbar = navcon.navigationBar
            navbar.prefersLargeTitles = true
            navcon.view.backgroundColor = .systemBackground
        }
        setupCompassButton()
        setupUserTrackingButtonAndScaleView()
        registerAnnotationViewClasses()
        
        self.updatePins()

        
        if (CLLocationManager.locationServicesEnabled())  {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let locationAuthorized = status == .authorizedWhenInUse
        userTrackingButton.isHidden = !locationAuthorized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clickRefresh(self)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            mapView.setCenter(center, animated: true)
        }
    }
    
    @IBAction func clickRefresh(_ sender: Any) {
        if (CLLocationManager.locationServicesEnabled())  {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func updatePins() {
        
        do {
            
            let csv: CSV = try CSV(url: URL(string: "https://raw.githubusercontent.com/iceweasel1/COVID-19-Germany/master/germany_with_source.csv")!)
            
            try  csv.enumerateAsDict({ (dict) in
                //   print(dict["name"])
                
                if let longS = dict["Longitude"] ,
                    let latS = dict["Latitude"] ,
                    let district = dict["District"],
                    let date = dict["Date"] ,
                    let long = Double(longS), let lat = Double(latS){
                    let cycle = Cycle()
                    cycle.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    self.mapView.addAnnotation(cycle)
                    
                }
                
                
            })
            
        } catch let parseError as CSVParseError {
            print(parseError)
            // Catch errors from parsing invalid formed CSV
        } catch {
            // Catch errors from trying to load files
        }
        
        
        
        
    }
    
    private func setupCompassButton() {
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .visible
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: compass)
        mapView.showsCompass = false
    }
    
    private func setupUserTrackingButtonAndScaleView() {
        mapView.showsUserLocation = true
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.isHidden = true // Unhides when location authorization is given.
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userTrackingButton)
        
        // By default, `MKScaleView` uses adaptive visibility, so it only displays when zooming the map.
        // This is behavior is confirgurable with the `scaleVisibility` property.
        scaleView = MKScaleView(mapView: mapView)
        scaleView.legendAlignment = .trailing
        view.addSubview(scaleView)
        
        let stackView = UIStackView(arrangedSubviews: [scaleView, userTrackingButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                                     stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)])
    }
    
    private func registerAnnotationViewClasses() {
        mapView.register(UnicycleAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    
 }
 
 
 
 extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Cycle else { return nil }
        
        switch annotation.type {
        case .unicycle:
            return UnicycleAnnotationView(annotation: annotation, reuseIdentifier: UnicycleAnnotationView.ReuseID)
            
        }
    }
 }
 
