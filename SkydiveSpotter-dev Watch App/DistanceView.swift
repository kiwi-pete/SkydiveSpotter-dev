import SwiftUI

struct DistanceView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var currentDistance: Double = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text("Distance:")
                .font(.title)
                .padding(.top, 50)
            Text("\(currentDistance, specifier: "%.3f") miles")
                .font(.largeTitle)
                .padding(.top, 20)
        }
        .onReceive(timer) { _ in
            updateDistance()
        }
        .navigationTitle("Distance")
    }
    
    private func updateDistance() {
        guard let savedLocation = locationManager.savedLocation,
              let currentLocation = locationManager.currentLocation else { return }
        
        let distanceInMeters = currentLocation.distance(from: savedLocation)
        currentDistance = distanceInMeters / 1609.34  // Convert meters to miles
    }
}

