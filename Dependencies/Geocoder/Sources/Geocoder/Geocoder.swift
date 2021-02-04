import CoreLocation

public struct Geocoder {
  public var reverseGeocodeLocation: (_ location: CLLocation, _ completion: @escaping (String?) -> Void) -> ()
}
