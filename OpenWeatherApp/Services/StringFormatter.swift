//
// Created by Allan Spreys on 08/12/2022.
//

import Foundation

enum StringFormatter {
  private static let temperatureFormatter = {
    let formatter = MeasurementFormatter()
    formatter.locale = Locale(identifier: "en_GB")
    formatter.numberFormatter.maximumFractionDigits = 0
    return formatter
  }()

  static func formatTemperature(_ temperature: Double) -> String {
    let measurement = Measurement(value: temperature, unit: UnitTemperature.celsius)
    return temperatureFormatter.string(from: measurement)
  }
}