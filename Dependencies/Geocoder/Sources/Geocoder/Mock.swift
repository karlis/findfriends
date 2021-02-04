extension Geocoder {
  public static var mock = Geocoder { location, completion in
    completion("Pūces iela 2b, Cēsis")
  }
}
