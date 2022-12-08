//
// Created by Allan Spreys on 07/12/2022.
//

import Foundation

protocol CredentialsProvider {
  var openWeatherApiKey: String { get }
}

struct CredentialsProviderImpl: CredentialsProvider {
  var openWeatherApiKey: String {
    fatalError("Please provide an Open Weather API key")
    return ""
  }
}
