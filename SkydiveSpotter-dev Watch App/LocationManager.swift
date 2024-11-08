import Foundation
import CoreLocation
import SwiftUI
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    @Published var currentLocation: CLLocation?
    @Published var smoothedCourse: Double = 0.0  // Smoothed heading direction, rounded to 5 degrees
    
    private var recentCourses: [Double] = []  // Stores the last 3 valid course readings
    private var lastValidCourseUpdateTime = Date() // Track the last time a valid course was updated
    
    private var updateMonitorTimer: Timer?  // Timer to check for continuous updates
    private var forcedRestartTimer: Timer?  // Timer to periodically restart location updates
    
    @AppStorage("savedLatitude") private var savedLatitude: Double?
    @AppStorage("savedLongitude") private var savedLongitude: Double?
    
    override init() {
        super.init()
        initializeLocationManager()
        requestLocationAuthorization()
        
        // Start a timer to monitor updates and a forced restart timer
        startUpdateMonitorTimer()
        startForcedRestartTimer()
    }
    
    private func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = kCLDistanceFilterNone
        startUpdatingLocation()
    }
    
    private func requestLocationAuthorization() {
        if locationManager?.authorizationStatus == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    private func startUpdatingLocation() {
        print("Starting location updates")
        locationManager?.startUpdatingLocation()
    }
    
    private func stopUpdatingLocation() {
        print("Stopping location updates")
        locationManager?.stopUpdatingLocation()
    }
    
    func setLocation() {
        if let location = locationManager?.location {
            savedLatitude = location.coordinate.latitude
            savedLongitude = location.coordinate.longitude
            print("Saved Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            stopUpdatingLocation()
            startUpdatingLocation()
        } else {
            print("Failed to obtain current location.")
        }
    }
    
    func getSavedLocation() -> CLLocation? {
        if let lat = savedLatitude, let lon = savedLongitude {
            return CLLocation(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        currentLocation = latestLocation
        addCourseReading(latestLocation.course)
        print("Current Location Updated: \(latestLocation.coordinate.latitude), \(latestLocation.coordinate.longitude)")
        print("Smoothed Course (Rounded to 5 degrees): \(smoothedCourse) degrees")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startUpdatingLocation()
        } else {
            print("Location authorization not granted.")
        }
    }
    
    // Add a course reading and update the smoothed course
    private func addCourseReading(_ course: Double) {
        // Ignore invalid or negative course values
        guard course >= 0 else { return }
        
        // Update the last valid course time
        lastValidCourseUpdateTime = Date()
        
        // Append the new course reading to recentCourses
        recentCourses.append(course)
        
        // Keep only the last 3 readings
        if recentCourses.count > 3 {
            recentCourses.removeFirst()
        }
        
        // Smooth the course by averaging, ensuring it doesn't jump too drastically
        let averageCourse = recentCourses.reduce(0, +) / Double(recentCourses.count)
        
        if abs(averageCourse - smoothedCourse) < 45 {
            // Round to the nearest 5 degrees
            smoothedCourse = round(averageCourse / 5) * 5
        }
    }
    
    private func startUpdateMonitorTimer() {
        updateMonitorTimer?.invalidate()
        
        updateMonitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForCourseUpdate()
        }
    }
    
    private func stopUpdateMonitorTimer() {
        updateMonitorTimer?.invalidate()
        updateMonitorTimer = nil
    }
    
    private func startForcedRestartTimer() {
        forcedRestartTimer?.invalidate()
        
        forcedRestartTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.forceRestartLocationUpdates()
        }
    }
    
    private func forceRestartLocationUpdates() {
        print("Forcing location updates restart to avoid freezing")
        stopUpdatingLocation()
        initializeLocationManager()  // Reinitialize location manager to reset
    }
    
    // Remove the reset logic from this function
    func checkForCourseUpdate() {
        let timeSinceLastUpdate = Date().timeIntervalSince(lastValidCourseUpdateTime)
        
        // Only print a message for now to observe if updates stall
        if timeSinceLastUpdate > 5 {
            print("Warning: No recent updates received for over 5 seconds")
        }
    }
    
    deinit {
        stopUpdateMonitorTimer()  // Clean up timer when this instance is deallocated
        forcedRestartTimer?.invalidate()
    }
}

