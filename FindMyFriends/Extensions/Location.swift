import CoreLocation
import TCPClient

extension Location {
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: latitude,
      longitude: longitude
    )
  }

  var clLocation: CLLocation {
    CLLocation(
      latitude: latitude,
      longitude: longitude
    )
  }
}
