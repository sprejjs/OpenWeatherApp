//
// Created by Allan Spreys on 07/12/2022.
//

import Foundation
import RealmSwift

final class CurrentWeather: Object, Decodable {
  @Persisted(primaryKey: true) private var id: Int
  @Persisted private (set) var locationName: String
  @Persisted private (set) var temperature: Double
  @Persisted private var weatherIcon: String

  var iconUrl: URL? {
    URL(string: "https://openweathermap.org/img/wn/\(weatherIcon)@2x.png")
  }

  private enum CodingKeys: CodingKey {
    case id
    case main
    case name
    case weather
  }

  private enum MainCodingKeys: CodingKey {
    case temp
  }

  convenience init(from decoder: Decoder) throws {
    self.init()

    let container = try? decoder.container(keyedBy: CodingKeys.self)
    let mainContainer = try? container?.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)

    id = try container?.decode(Int.self, forKey: .id) ?? 0
    locationName = try container?.decode(String.self, forKey: .name) ?? ""
    temperature = try mainContainer?.decode(Double.self, forKey: .temp) ?? 0

    let weatherObjects = try container?.decode([Weather].self, forKey: .weather)
    weatherIcon = weatherObjects?.first?.icon ?? ""
  }

  private struct Weather: Decodable {
    let icon: String
  }
}