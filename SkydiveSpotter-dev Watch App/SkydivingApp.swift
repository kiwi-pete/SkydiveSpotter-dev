import SwiftUI

@main
struct SkydivingApp: App {
    var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                SetLocationView()
                    .tabItem {
                        Label("Set Location", systemImage: "location.fill")
                    }
                DistanceView(locationManager: locationManager)
                    .tabItem {
                        Label("Distance", systemImage: "map.fill")
                    }
            }
        }
    }
}

