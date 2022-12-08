//
// Created by Allan Spreys on 07/12/2022.
//

import Foundation
import CoreLocation

protocol LocationManager {
  func requestLocation(_ completionHandler: @escaping (Result<LocationCoordinate, Error>) -> Void)
}

final class LocationManagerImpl: NSObject, ObservableObject, LocationManager {
  private var completionHandlers: [(Result<LocationCoordinate, Error>) -> Void] = []
  private let manager = CLLocationManager()

  override init() {
    super.init()
    manager.delegate = self
  }

  func requestLocation(_ completionHandler: @escaping (Result<LocationCoordinate, Error>) -> Void) {
    completionHandlers.append(completionHandler)
    manager.requestLocation()
  }
}

extension LocationManagerImpl: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }

    let locationCoordinate = LocationCoordinate(lat: location.coordinate.latitude, lon: location.coordinate.longitude)

    for completionHandler in completionHandlers {
      completionHandler(.success(locationCoordinate))
    }
    completionHandlers.removeAll()
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    for completionHandler in completionHandlers {
      completionHandler(.failure(error))
    }
    completionHandlers.removeAll()
  }
}