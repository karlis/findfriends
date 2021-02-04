import CoreLocation

extension Geocoder {
  public static var live = Geocoder { location, completion in
    CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
      completion(placemarks?.first?.formattedLocationName)
    }
  }
}
