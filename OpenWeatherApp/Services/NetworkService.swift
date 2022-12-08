//
// Created by Allan Spreys on 03/12/2022.
//

import Foundation

enum ApiError: Error, LocalizedError {
  case unknown

  var errorDescription: String? {
    switch self {
    case .unknown:
      return "An unknown error occurred"
    }
  }
}

protocol NetworkService {
  func makeRequest<Item: Decodable>(
    forUrl url: String,
    type: Item.Type,
    queryParameters: [String: String],
    completion: @escaping (Result<Item, ApiError>) -> Void)
}

final class NetworkServiceImpl: NetworkService {
  private let decoder: JSONDecoder = JSONDecoder()

  func assembleUrl(
    url: String,
    queryParameters: [String: String]
  ) -> URL? {
    guard var components = URLComponents(string: url) else {
      assertionFailure("Unable to assemble the URL")
      return nil
    }

    components.queryItems = queryParameters.compactMap { key, value in
      URLQueryItem(name: key, value: value)
    }

    guard let url = components.url else {
      assertionFailure("Unable to assemble the URL")
      return nil
    }

    return url
  }

  func makeRequest<Item: Decodable>(
    forUrl url: String,
    type: Item.Type,
    queryParameters: [String: String],
    completion: @escaping (Result<Item, ApiError>) -> Void
  ) {
    guard let url = assembleUrl(url: url, queryParameters: queryParameters) else {
      assertionFailure("Unable to assemble the URL")
      completion(.failure(.unknown))
      return
    }

    let urlRequest = URLRequest(url: url)

    let task = URLSession.shared.dataTask(with: urlRequest) { [weak decoder] data, response, error in
      guard error == nil else {
        completion(.failure(.unknown))
        return
      }

      guard let data = data else {
        completion(.failure(.unknown))
        return
      }

      if let decoded = try? decoder?.decode(Item.self, from: data) {
        completion(.success(decoded))
      } else {
        completion(.failure(.unknown))
      }
    }

    task.resume()
  }
}