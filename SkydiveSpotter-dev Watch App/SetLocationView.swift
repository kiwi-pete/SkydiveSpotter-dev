import SwiftUI

struct SetLocationView: View {
    @ObservedObject var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Button("Set Location") {
                locationManager.setLocation()
            }
            .padding()
            .font(.title2)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 50)
            
            if let location = locationManager.getSavedLocation() {  // Use the getter method here
                Text("Latitude: \(location.coordinate.latitude)")
                    .padding(.top, 20)
                Text("Longitude: \(location.coordinate.longitude)")
            } else {
                Text("Location not set")
                    .padding(.top, 20)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Set Location")
    }
}

