//
// Created by Allan Spreys on 08/12/2022.
//

import Foundation
import RealmSwift

final class WeatherForecast: Object, Decodable {
  @Persisted(primaryKey: true) private(set) var id: Int
  @Persisted private(set) var temperature: Double
  @Persisted private(set) var date: String
  @Persisted private var weatherIcon: String

  var iconUrl: URL? {
    URL(string: "https://openweathermap.org/img/wn/\(weatherIcon)@2x.png")
  }

  private enum CodingKeys: CodingKey {
    case dt
    case dt_txt

    case main
    case weather
  }

  private enum MainCodingKeys: CodingKey {
    case temp
  }

  convenience init(from decoder: Decoder) throws {
    self.init()

    let container = try? decoder.container(keyedBy: CodingKeys.self)
    let mainContainer = try? container?.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)

    id = try container?.decode(Int.self, forKey: .dt) ?? 0
    temperature = try mainContainer?.decode(Double.self, forKey: .temp) ?? 0
    date = try container?.decode(String.self, forKey: .dt_txt) ?? ""

    let weatherObjects = try container?.decode([Weather].self, forKey: .weather)
    weatherIcon = weatherObjects?.first?.icon ?? ""
  }

  private struct Weather: Decodable {
    let icon: String
  }
}

struct WeatherForecastResponse: Decodable {
  let list: [WeatherForecast]
}