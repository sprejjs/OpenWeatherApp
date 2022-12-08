//
// Created by Allan Spreys on 07/12/2022.
//

import Foundation
import RealmSwift

protocol WeatherViewModel: ObservableObject {
  func didTapLocationButton()

  var viewState: WeatherViewState { get }
}

final class WeatherViewModelImpl: WeatherViewModel {
  private let locationManager: LocationManager
  private let weatherService: OpenApiWeatherService

  private var model = Model() {
    didSet {
      updateViewState()
    }
  }

  @Published private(set) var viewState: WeatherViewState = .requiresPermission

  init(
    locationManager: LocationManager = LocationManagerImpl(),
    weatherService: OpenApiWeatherService = OpenApiWeatherServiceImpl()
  ) {
    self.locationManager = locationManager
    self.weatherService = weatherService

    subscribeToNotifications()
  }

  private func updateViewState() {
    DispatchQueue.main.async {
      switch self.model.locationPermissionState {
      case .notProvided:
        self.viewState = .requiresPermission
        return
      case .denied:
        self.viewState = .locationError
        return
      case .provided:
        self.viewState = .permissionGranted(
          self.currentWeatherViewState,
          self.weatherForecastViewState
        )
        break
      }
    }
  }

  private func subscribeToNotifications() {
    do {
      let realm = try Realm()
      let currentWeatherResult = realm.objects(CurrentWeather.self)

      model.currentWeatherNotificationToken = currentWeatherResult.observe { [weak self] change in
        switch change {
        case .initial(let results):
          guard let result = results.first else { return }
          self?.model.currentWeatherState = .loaded(result)
        case .update(let results, _, _, _):
          guard let result = results.first else { return }
          self?.model.currentWeatherState = .loaded(result)
        case .error(let error):
          self?.model.currentWeatherState = .error(error.localizedDescription)
        }
      }

      let weatherForecastResult = realm.objects(WeatherForecast.self)

      model.weatherForecastNotificationToken = weatherForecastResult.observe { [weak self] change in
        switch change {
        case .initial(let results):
          self?.model.weatherForecastState = .loaded(results.map { $0 })
        case .update(let results, _, _, _):
          self?.model.weatherForecastState = .loaded(results.map { $0 })
        break
        case .error(let error):
          self?.model.weatherForecastState = .error(error.localizedDescription)
        }
      }

    } catch {
      assertionFailure("Unable to subscribe to notifications")
    }
  }

  func didTapLocationButton() {
    locationManager.requestLocation { [weak self] result in
      self?.handleLocationPermissionResult(result)
    }
  }

  func handleLocationPermissionResult(_ result: Result<LocationCoordinate, Error>) {
    switch result {
    case .success(let location):
      model.locationPermissionState = .provided

      weatherService.fetchCurrentWeather(location: location) { [weak self] result in
        self?.handleFetchCurrentWeatherResult(result)
      }

      weatherService.fetchWeatherForecast(location: location) { [weak self] result in
        self?.handleWeatherForecastResult(result)
      }
    case .failure:
      model.locationPermissionState = .denied
    }
  }

  func handleFetchCurrentWeatherResult(_ result: Result<CurrentWeather, ApiError>) {
    switch result {
    case .success(let currentWeather):
      do {
        let realm = try Realm()
        try realm.write {
          realm.delete(realm.objects(CurrentWeather.self))
          realm.add(currentWeather, update: .all)
        }
      } catch {
        assertionFailure("Unable to save current weather to Realm")
        model.currentWeatherState = .loaded(currentWeather)
      }

    case .failure(let error):
      model.currentWeatherState = .error(error.localizedDescription)
    }
  }

  func handleWeatherForecastResult(_ result: Result<[WeatherForecast], ApiError>) {
    switch result {
    case .success(let weatherForecast):
      do {
        let realm = try Realm()
        try realm.write {
          realm.delete(realm.objects(WeatherForecast.self))
          realm.add(weatherForecast, update: .all)
        }
      } catch {
        assertionFailure("Unable to save weather forecast to Realm")
        model.weatherForecastState = .loaded(weatherForecast)
      }
    case .failure(let error):
      model.weatherForecastState = .error(error.localizedDescription)
    }
  }
}

extension WeatherViewModelImpl {
  struct Model {
    var locationPermissionState: LocationPermissionState = .notProvided
    var currentWeatherState: ModelState<CurrentWeather> = .loading
    var weatherForecastState: ModelState<[WeatherForecast]> = .loading
    var currentWeatherNotificationToken: NotificationToken?
    var weatherForecastNotificationToken: NotificationToken?

    enum LocationPermissionState {
      case notProvided
      case provided
      case denied
    }

    enum ModelState<Model> {
      case loading
      case loaded(Model)
      case error(String)
    }
  }
}

extension WeatherViewModelImpl {
  private var currentWeatherViewState: WeatherViewState.CurrentWeather {
    switch model.currentWeatherState {
    case .loading:
      return .loading
    case .loaded(let weather):
      let state = WeatherViewState.CurrentWeather.State(
        locationName: weather.locationName,
        temperature: StringFormatter.formatTemperature(weather.temperature),
        iconUrl: weather.iconUrl
      )
      return .loaded(state)
    case .error(let error):
      return .error(error)
    }
  }

  private var weatherForecastViewState: WeatherViewState.WeatherForecast {
    switch model.weatherForecastState {
    case .loading:
      return .loading
    case .loaded(let weatherForecast):
      return .loaded(weatherForecast.map { weather in
        .init(
          id: weather.id,
          date: weather.date,
          temperature: StringFormatter.formatTemperature(weather.temperature),
          iconUrl: weather.iconUrl
        )
      })
    case .error(let error):
      return .error(error)
    }
  }
}