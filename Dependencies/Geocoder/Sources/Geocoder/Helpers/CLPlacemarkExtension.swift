import CoreLocation

extension CLPlacemark {
  var formattedLocationName: String {
    [name, locality]
      .compactMap { $0 }
      .joined(separator: ", ")
  }
}
