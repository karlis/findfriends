import Foundation
import Combine

/// Simple utility to fetch a image data from URL
public struct ImageFetcher {
  public var fetch: (_ url: URL) -> AnyPublisher<Data, URLError>
}
