//
//  GeofencingManager.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 29/07/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

/// Geofence with Notification local when enter in region
/// Not forget to add NSLocationAlwaysAndWhenInUseUsageDescription and NSLocationWhenInUseUsageDescription Key in Plist
/// And add Background mode "location update" in Capatibility
class GeofencingManager: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    static let shared = GeofencingManager()
    
    static let defaultAccuracyRadius: CLLocationDistance = 200
    
    private let locationManager = CLLocationManager()
    private let offerWorker = OfferWorker()
    
    private var offers: [Offer] = [] {
        didSet {
            self.geofences = self.offers.map(self.tranformOfferToGeofence(_:))
        }
    }
    
    var geofences: [GeofenceModel] = []
    var geofencesMonitored: [GeofenceModel] = []
    
    var onCommitLocationUpdate: ((CLLocation) -> Void)?
    
    // MARK: - Start
    func start(offers: [Offer]) {
        // Ask user notification permisson
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        notificationCenter.requestAuthorization(options: options) { success, error in
            if let error = error {
                print(error)
            }
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        #if !DEBUG
            self.locationManager.distanceFilter = 200
        #endif
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.requestAlwaysAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForegroundNotification(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.offers = offers
    }
    
    // MARK: - Geofences
    private func getGeofence(by id: String) -> GeofenceModel? {
        return self.geofences.first(where: { $0.id == id })
    }
    
    private func getRandomGeofencesForTest() -> [GeofenceModel] {
        func getLatLong(my_lat: Double, my_long: Double, meters: Double = 200) -> (Double, Double) {
            
            // number of km per degree = ~111km (111.32 in google maps, but range varies
            //  between 110.567km at the equator and 111.699km at the poles)
            // 1km in degree = 1 / 111.32km = 0.0089
            // 1m in degree = 0.0089 / 1000 = 0.0000089
            let coef: Double = meters * 0.0000089

            let new_lat: Double = my_lat + coef

            // pi / 180 = 0.018
            let new_long: Double = my_long + coef / cos(my_lat * 0.018)
            
            return (new_lat, new_long)
        }
        
        var geofences = [GeofenceModel]()
        var initialLat: Double = 44.82504714846246
        var initialLng: Double = -0.6711615625412848
        
        for i in 1...40 {
            let randLat = Double.random(in: 44.82580558496267 ... 44.835301411801964)
            let randLong = Double.random(in: -0.674727529067729 ... -0.6564026770779829)
            
            let geofence = GeofenceModel(id: UUID().uuidString,
                                         coordinate: CLLocationCoordinate2D(latitude: randLat, longitude: randLong),
                                         name: "\(i) Place",
                                         content: "Some content")
            geofences.append(geofence)
            
            let (newLat, newLng) = getLatLong(my_lat: initialLat, my_long: initialLng)
            initialLat = newLat
            initialLng = newLng
        }
        
        return geofences
    }
    
    // MARK: - Transform
    private func tranformOfferToGeofence(_ offer: Offer) -> GeofenceModel {
        return GeofenceModel(id: offer.id,
                             coordinate: CLLocationCoordinate2D(latitude: offer.latitude, longitude: offer.longitude),
                             name: offer.name,
                             content: offer.description)
    }
    
    private func region(with geofence: GeofenceModel) -> CLCircularRegion {
        let region = CLCircularRegion(center: geofence.coordinate,
                                      radius: GeofencingManager.defaultAccuracyRadius,
                                      identifier: geofence.id)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        return region
    }
    
    // MARK: - Monitoring
    private func checkMonitoringAvailable() -> Bool {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            return false
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            return false
        }
        return true
    }
    
    private func startMonitoring(geofence: GeofenceModel) {
        let region = self.region(with: geofence)
        locationManager.startMonitoring(for: region)
    }
    
    private func stopMonitoring(geofence: GeofenceModel) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geofence.id else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    private func stopMonitoringAllGeofences() {
        self.locationManager.monitoredRegions.forEach { region in
            self.locationManager.stopMonitoring(for: region)
        }
    }
    
    private func updateGeofencesMonitoring(with userLocation: CLLocation) {
        self.checkAuthorizeNotification { [weak self] isAuthorize in
            if self?.checkMonitoringAvailable() == false && !isAuthorize {
                return
            }
            
            self?.stopMonitoringAllGeofences()
            self?.geofencesMonitored = self?.geofences
                .sorted(by: {
                    CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude).distance(from: userLocation)
                        <
                    CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude).distance(from: userLocation)
                })
                .prefix(20)
                .compactMap({$0}) as! [GeofenceModel]
                
            self?.geofencesMonitored.forEach {
                self?.startMonitoring(geofence: $0)
            }
        }
    }
    
    // MARK: - Notification
    private func checkAuthorizeNotification(completion: @escaping (Bool)->()) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .authorized:
                    completion(true)
                default:
                    completion(false)
            }
        }
    }
    
    private func sendNotification(geofenceId: String) {
        guard let geofence = self.getGeofence(by: geofenceId) else {
            return
        }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = geofence.name
        notificationContent.body = geofence.content
        notificationContent.sound = UNNotificationSound.default
        notificationContent.userInfo = ["id": geofence.id]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "geofence_enter_\(geofenceId)",
                                            content: notificationContent,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    // MARK: - Background Refresh
    @objc func applicationWillEnterForegroundNotification(notification: NSNotification) {
        self.offerWorker.getOffers() { [weak self] result in
            self?.offers = (try? result.get()) ?? []
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension GeofencingManager {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if self.checkMonitoringAvailable() {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.first as Any)
        if let userLocation = locations.first {
            self.onCommitLocationUpdate?(userLocation)
            self.updateGeofencesMonitoring(with: userLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Enter in Region")
        
        let today = Date()
        let lastDateSendedGeofenceNotification = UserDefaults.standard.object(forKey: GeofencingConfiguration.lastDateSendedGeofenceNotificationUserDefault) as? Date
        
        func saveCurrentDateAndSendNotif() {
            UserDefaults.standard.set(today, forKey: GeofencingConfiguration.lastDateSendedGeofenceNotificationUserDefault)
            self.sendNotification(geofenceId: region.identifier)
        }
        
        guard let lastDate = lastDateSendedGeofenceNotification else {
            saveCurrentDateAndSendNotif()
            return
        }

        let lastDateWithDelay = lastDate.addingTimeInterval(GeofencingConfiguration.delayPushGeofencing)
        if lastDateWithDelay.compare(today) == .orderedSame || lastDateWithDelay.compare(today) == .orderedAscending {
            saveCurrentDateAndSendNotif()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//// MARK: - UNUserNotificationCenterDelegate
//extension GeofencingManager {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        completionHandler()
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert, .badge, .sound])
//    }
//}
