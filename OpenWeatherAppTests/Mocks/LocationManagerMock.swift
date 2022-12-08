//
// Created by Allan Spreys on 08/12/2022.
//

import Foundation

final class LocationManagerMock: LocationManager {
  var requestLocationResult: Result<LocationCoordinate, Error> = .success(LocationCoordinate(lat: 0, lon: 0))

  func requestLocation(_ completionHandler: @escaping (Result<LocationCoordinate, Error>) -> ()) {
    completionHandler(requestLocationResult)
  }
}