import Combine
import UIKit.UIImage

extension ImageFetcher {
  public static var mock = ImageFetcher { _ in
    Just(UIImage(systemName: "bicycle.circle.fill")?.pngData() ?? Data())
      .setFailureType(to: URLError.self)
      .eraseToAnyPublisher()
  }
}
