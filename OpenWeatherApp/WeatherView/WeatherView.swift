//
//  WeatherView.swift
//  OpenWeatherApp
//
//  Created by Allan Spreys on 07/12/2022.
//

import SwiftUI
import CoreLocationUI

struct WeatherView<ViewModel: WeatherViewModel>: View {
  @ObservedObject private var viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    switch viewModel.viewState {
    case .requiresPermission:
      requiresPermissionView
    case .locationError:
      Text("We couldn't determine your location. Please try again later.")
    case .permissionGranted:
      VStack {
        currentWeatherView
          .padding(.top, Constants.edgePadding)
        Spacer()
        weatherForecastView
      }
    }
  }

  @ViewBuilder
  private var currentWeatherView: some View {
    if case let .permissionGranted(currentWeather, _) = viewModel.viewState {
      switch currentWeather {
      case .loading:
        loadingView
      case .loaded(let state):
        VStack {
          Text(state.locationName)
          Text(state.temperature)
          if let iconUrl = state.iconUrl {
            AsyncImage(url: iconUrl) { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
            } placeholder: {
              ProgressView()
            }.frame(width: Constants.currentWeatherIconSize, height: Constants.currentWeatherIconSize)
          }
        }
      case .error(let error):
        Text(error)
      }
    }
  }

  @ViewBuilder
  private var weatherForecastView: some View {
    if case let .permissionGranted(_, weatherForecast) = viewModel.viewState {
      switch weatherForecast {
      case .loading:
        VStack {
          loadingView
          Spacer()
        }
      case .loaded(let forecast):
        List {
          ForEach(forecast, id: \.id) { state in
            HStack {
              Text(state.date)
              Spacer()
              Text(state.temperature)
              if let iconUrl = state.iconUrl {
                AsyncImage(url: iconUrl) { image in
                  image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                } placeholder: {
                  ProgressView()
                }.frame(width: Constants.weatherForecastIconSize, height: Constants.weatherForecastIconSize)
              }
            }
          }
        }
      case .error(let error):
        VStack {
          Text(error)
          Spacer()
        }
      }
    }
  }

  private var loadingView: some View {
    VStack(spacing: Constants.standardPadding) {
      ProgressView()
      Text("Loading...")
    }
  }

  private var requiresPermissionView: some View {
    VStack {
      Text("Please share your location to get the weather")
        .font(.title)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)
        .padding()

      LocationButton {
        viewModel.didTapLocationButton()
      }
        .foregroundColor(.white)
    }
  }
}

private enum Constants {
  static let edgePadding: CGFloat = 16
  static let standardPadding: CGFloat = 8
  static let currentWeatherIconSize: CGFloat = 60
  static let weatherForecastIconSize: CGFloat = 30
}
