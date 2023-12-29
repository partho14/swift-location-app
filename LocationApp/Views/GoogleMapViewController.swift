//
//  GoogleMapViewController.swift
//  LocationTracker
//
//  Created by Partha Pratim on 28/12/23.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class GoogleMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let center = UNUserNotificationCenter.current()

    
    private lazy var locationManager: CLLocationManager = {
          let manager = CLLocationManager()
          manager.desiredAccuracy = kCLLocationAccuracyBest
          manager.delegate = self
          manager.requestAlwaysAuthorization()
          manager.allowsBackgroundLocationUpdates = true
          manager.pausesLocationUpdatesAutomatically = false
          return manager
        }()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    let destinationLat = 23.75374625
    let destinationLng = 91.37823556
    
    let viewModel = GoogleMapDataSync.sharedInstance
    
    var coordinateArray: [Payload] = [Payload]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingIndicatorView.show()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.showsTraffic = true
        mapView.delegate = self
        mapView.isPitchEnabled = true
        mapView.showsBuildings = true
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        locationManager.startUpdatingLocation()
                
        //todo ask permision for local notification
        center.requestAuthorization(options: [.alert,.sound]) { result, err in
            if err == nil {
                if result {
                    print("Granted")
                }else{
                    print("Permision denied")
                }
            }else{
                print("Error--- \(err!.localizedDescription)")
            }
        }
        viewModel.fetchData()
    }
    
    func alertForUpdatingLocation(_ locationData:String){
           
        //Create content
        let content = UNMutableNotificationContent()
        content.title = "You Reached your Deestination"
        content.body = locationData
        
        //create request
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        center.add(req) { err in
            if (err != nil) {
                print(err!.localizedDescription)
            }else{
                print("notification fired")
            }
        }
    }
    
    
    func reloadData(){
        checkLocationServices()
    }
    
    @objc func appMovedToBackground() {
      print("App moved to background!")
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            LoadingIndicatorView.hide()
            checkLocationAuthorization()
        } else {
            LoadingIndicatorView.hide()
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            startTackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    
    func startTackingUserLocation(){
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    
    
}


extension GoogleMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


extension GoogleMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        guard self.previousLocation != nil else { return }
        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude), latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        guard center.distance(from: CLLocation(latitude: destinationLat, longitude: destinationLng)) < 50 else { return }
        self.previousLocation = center
        self.mapView.setRegion(region, animated: true)
    }
    
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = getCenterLocation(for: mapView)
        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        print(userLocation)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         
        guard let mostRecentLocation = locations.last else {
            return
          }
        
        let locationA = CLLocation(latitude: mostRecentLocation.coordinate.latitude, longitude: mostRecentLocation.coordinate.longitude)

          
          if UIApplication.shared.applicationState == .active {
            
              for coor in self.coordinateArray {
                  let dbLat = Double(coor.latitude!)  // Convert String to double
                  let dbLong = Double(coor.longitude!)
                  
                  let locationB = CLLocation(latitude: dbLat!, longitude: dbLong!)
                  let distanceInMeters = locationA.distance(from: locationB)
                  
                  if distanceInMeters <= 50{
                      let alert = UIAlertController(title: "Reached your Deestination", message: "\(coor.address!)", preferredStyle: UIAlertController.Style.alert)
                      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                      self.present(alert, animated: true, completion: nil)
                  } else { return }
              }
          } else {
              for coor in self.coordinateArray {
                  let dbLat = Double(coor.latitude!)  // Convert String to double
                  let dbLong = Double(coor.longitude!)
                  
                  let locationB = CLLocation(latitude: dbLat!, longitude: dbLong!)
                  let distanceInMeters = locationA.distance(from: locationB)
                  
                  if distanceInMeters <= 50{
                      alertForUpdatingLocation("\(coor.address!)")
                  } else { return }
              }
          }
        }

}
