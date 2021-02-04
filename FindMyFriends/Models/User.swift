import TCPClient

struct User: Equatable, Hashable {
  let id: String
  let title: String
  var subtitle: String?
  let imageUrl: String?
  var location: Location
}
