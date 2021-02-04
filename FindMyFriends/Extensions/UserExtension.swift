import TCPClient

extension TCPClient.User {
  var user: User {
    User(
      id: id,
      title: name,
      imageUrl: image,
      location: location
    )
  }
}

extension User {
  var annotation: UserAnnotation {
    UserAnnotation(
      id: id,
      title: title,
      imageUrl: imageUrl,
      subtitle: subtitle,
      location: location
    )
  }
}
