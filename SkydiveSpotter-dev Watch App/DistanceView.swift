import SwiftUI

struct DistanceView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var currentDistance: Double = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 12) {  // Slightly increased spacing for clarity
            Text("Distance")
                .font(.title3)  // Slightly larger title font
            Text("\(currentDistance, specifier: "%.3f") miles")
                .font(.title2)  // Larger font for distance display
                .padding(.top, 6)
            
            // Display the smoothed heading direction
            Text("Heading: \(locationManager.smoothedCourse, specifier: "%.0f")°")
                .font(.headline)  // Larger font for heading
                .padding(.top, 6)
            
            // Display current GPS coordinates
            if let currentLocation = locationManager.currentLocation {
                VStack(spacing: 6) {
                    Text("Lat: \(currentLocation.coordinate.latitude, specifier: "%.6f")")
                        .font(.subheadline)  // Slightly larger font for coordinates
                    Text("Long: \(currentLocation.coordinate.longitude, specifier: "%.6f")")
                        .font(.subheadline)
                }
                .padding(.top, 8)
            } else {
                Text("Waiting for location data...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
        .onReceive(timer) { _ in
            updateDistance()
            locationManager.checkForCourseUpdate()  // Periodic check to prevent freezing
        }
        .navigationTitle("Distance")
    }
    
    private func updateDistance() {
        guard let savedLocation = locationManager.getSavedLocation(),
              let currentLocation = locationManager.currentLocation else {
            print("Saved location or current location not set.")
            return
        }
        
        let distanceInMeters = currentLocation.distance(from: savedLocation)
        let distanceInMiles = distanceInMeters / 1609.34  // Convert meters to miles
        currentDistance = distanceInMiles
        print("Distance in Miles: \(currentDistance)")
    }
}

