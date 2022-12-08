//
// Created by Allan Spreys on 08/12/2022.
//

import Foundation

final class WeatherServiceMock: OpenApiWeatherService {
  var fetchCurrentWeatherResult: Result<CurrentWeather, ApiError> = .success(CurrentWeather())
  var fetchWeatherForecastResult: Result<[WeatherForecast], ApiError> = .success([])

  func fetchCurrentWeather(location: LocationCoordinate, completion: @escaping (Result<CurrentWeather, ApiError>) -> ()) {
    completion(fetchCurrentWeatherResult)
  }

  func fetchWeatherForecast(location: LocationCoordinate, completion: @escaping (Result<[WeatherForecast], ApiError>) -> ()) {
    completion(fetchWeatherForecastResult)
  }
}