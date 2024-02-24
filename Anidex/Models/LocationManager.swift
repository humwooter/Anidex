//
//  LocationManager.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/23/24.
//

import Foundation
import MapKit


final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setup()
    }
    
    func requestLocation() {
        locationManager.requestLocation() 
    }
    
    func setup() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation() // request location if already authorized
        case .notDetermined:
            locationManager.startUpdatingLocation() // start location updates to trigger authorization request
            locationManager.requestWhenInUseAuthorization() // request when-in-use authorization
        default:
            break // do nothing for other cases
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate // update current location with the first received location
        locationManager.stopUpdatingLocation() // stop further location updates
        locations.last.map {
            region = MKCoordinateRegion( // update region based on the last received location
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation() // request location again if authorization status changes to authorized when in use
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)") // log any errors from location manager
    }
}
