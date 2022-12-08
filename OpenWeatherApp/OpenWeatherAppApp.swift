//
//  OpenWeatherAppApp.swift
//  OpenWeatherApp
//
//  Created by Allan Spreys on 07/12/2022.
//

import SwiftUI

@main
struct OpenWeatherAppApp: App {
  init() {
    URLCache.shared.memoryCapacity = 10_000_000
    URLCache.shared.diskCapacity = 50_000_000
  }

  var body: some Scene {
    WindowGroup {
      WeatherView(viewModel: WeatherViewModelImpl())
    }
  }
}
