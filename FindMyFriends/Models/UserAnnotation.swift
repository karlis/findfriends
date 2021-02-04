import MapKit
import TCPClient

class UserAnnotation: NSObject, MKAnnotation {
  let id: String
  let title: String?
  let imageUrl: String?
  var location: Location {
    didSet {
      coordinate = location.coordinate
    }
  }

  @objc dynamic var coordinate: CLLocationCoordinate2D
  @objc dynamic var subtitle: String? = nil

  init(
    id: String,
    title: String,
    imageUrl: String?,
    subtitle: String?,
    location: Location
  ) {
    self.id = id
    self.title = title
    self.imageUrl = imageUrl
    self.subtitle = subtitle
    self.location = location
    coordinate = location.coordinate
  }
}
