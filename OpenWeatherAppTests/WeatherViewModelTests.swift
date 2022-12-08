//
// Created by Allan Spreys on 08/12/2022.
//

import RealmSwift
import XCTest
import Combine

@testable import OpenWeatherApp

final class WeatherViewModelTests: XCTestCase {

  private var locationManager: LocationManagerMock!
  private var weatherService: WeatherServiceMock!
  private var subject: WeatherViewModelImpl!

  private var cancellables: Set<AnyCancellable> = []

  override func setUp() {
    super.setUp()
    locationManager = LocationManagerMock()
    weatherService = WeatherServiceMock()
    subject = WeatherViewModelImpl(
      locationManager: locationManager,
      weatherService: weatherService
    )

    Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
  }

  func test_didTapLocationButton_permissionGranted() {
    // GIVEN the location service grants the permission
    locationManager.requestLocationResult = .success(LocationCoordinate(lat: 0, lon: 0))
    let expectation = expectation(description: "didTapLocationButton_permissionGranted")

    // WHEN the user taps the location button
    subject.didTapLocationButton()

    // THEN the view state is set to permission granted
    subject
      .$viewState
      .dropFirst()
      .prefix(1)
      .sink { value in
        switch value {
        case .permissionGranted:
          XCTAssertTrue(true)
        default:
          XCTFail("Expected permission granted")
        }
        expectation.fulfill()
      }
      .store(in: &cancellables)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error)
    }
  }

  func test_didTapLocationButton_permissionDenied() {
    // GIVEN the location service denies the permission
    locationManager.requestLocationResult = .failure(ApiError.unknown)
    let expectation = expectation(description: "didTapLocationButton_permissionDenied")

    // WHEN the user taps the location button
    subject.didTapLocationButton()

    // THEN the view state is set to location error
    subject
      .$viewState
      .dropFirst()
      .prefix(1)
      .sink { value in
        switch value {
        case .locationError:
          XCTAssertTrue(true)
        default:
          XCTFail("Expected permission denied")
        }
        expectation.fulfill()
      }
      .store(in: &cancellables)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error)
    }
  }
}
