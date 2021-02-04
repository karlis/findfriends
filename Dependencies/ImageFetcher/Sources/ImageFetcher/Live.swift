import Combine
import Foundation

extension ImageFetcher {
  public static var live = ImageFetcher { url -> AnyPublisher<Data, URLError> in
    URLSession.shared
      .dataTaskPublisher(for: url)
      .map(\.data)
      .eraseToAnyPublisher()
  }
}
