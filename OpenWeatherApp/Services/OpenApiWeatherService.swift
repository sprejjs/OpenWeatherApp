//
// Created by Allan Spreys on 07/12/2022.
//

import Foundation

protocol OpenApiWeatherService {
  func fetchCurrentWeather(location: LocationCoordinate, completion: @escaping (Result<CurrentWeather, ApiError>) -> Void)
  func fetchWeatherForecast(location: LocationCoordinate, completion: @escaping (Result<[WeatherForecast], ApiError>) -> Void)
}

final class OpenApiWeatherServiceImpl: OpenApiWeatherService {
  private let credentialsProvider: CredentialsProvider
  private let networkService: NetworkService

  init(
    credentialsProvider: CredentialsProvider = CredentialsProviderImpl(),
    networkService: NetworkService = NetworkServiceImpl()
  ) {
    self.credentialsProvider = credentialsProvider
    self.networkService = networkService
  }

  func fetchCurrentWeather(location: LocationCoordinate, completion: @escaping (Result<CurrentWeather, ApiError>) -> ()) {
    let queryParams: [String: String] = [
      Constants.QueryParameters.lat: String(location.lat),
      Constants.QueryParameters.lon: String(location.lon),
      Constants.QueryParameters.apiKey: credentialsProvider.openWeatherApiKey,
      Constants.QueryParameters.units: Constants.metricUnits,
    ]

    networkService.makeRequest(
      forUrl: Constants.currentWeatherUrl,
      type: CurrentWeather.self,
      queryParameters: queryParams,
      completion: completion)
  }

  func fetchWeatherForecast(location: LocationCoordinate, completion: @escaping (Result<[WeatherForecast], ApiError>) -> ()) {
    let queryParams: [String: String] = [
      Constants.QueryParameters.lat: String(location.lat),
      Constants.QueryParameters.lon: String(location.lon),
      Constants.QueryParameters.apiKey: credentialsProvider.openWeatherApiKey,
      Constants.QueryParameters.units: Constants.metricUnits,
    ]

    networkService.makeRequest(
      forUrl: Constants.weatherForecastUrl,
      type: WeatherForecastResponse.self,
      queryParameters: queryParams
    ) { result in
      switch result {
      case .success(let response):
        completion(.success(response.list))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private enum Constants {
    static let currentWeatherUrl = "https://api.openweathermap.org/data/2.5/weather"
    static let weatherForecastUrl = "https://api.openweathermap.org/data/2.5/forecast"
    static let metricUnits = "metric"

    enum QueryParameters {
      static let lat = "lat"
      static let lon = "lon"
      static let units = "units"
      static let apiKey = "appid"
    }
  }
}