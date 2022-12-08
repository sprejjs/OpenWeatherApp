//
// Created by Allan Spreys on 08/12/2022.
//

import Foundation

enum WeatherViewState {
  case requiresPermission
  case locationError
  case permissionGranted(CurrentWeather, WeatherForecast)

  enum CurrentWeather {
    case loading
    case loaded(State)
    case error(String)

    struct State {
      let locationName: String
      let temperature: String
      let iconUrl: URL?
    }
  }

  enum WeatherForecast {
    case loading
    case loaded([State])
    case error(String)

    struct State {
      let id: Int
      let date: String
      let temperature: String
      let iconUrl: URL?
    }
  }
}