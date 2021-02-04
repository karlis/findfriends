import MapKit

class UserAnnotationView: MKAnnotationView {
  static let identifier: String = "UserAnnotationView"

  init(annotation: UserAnnotation) {
    super.init(annotation: annotation, reuseIdentifier: Self.identifier)

    leftCalloutAccessoryView = imageView
    canShowCallout = true

    // Set custom annotation image for our friends.
    if annotation.id == "101" {
      image = UIImage(systemName: "house.circle.fill")
    } else {
      image = UIImage(systemName: "bicycle.circle.fill")
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Subviews

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    imageView.contentMode = .scaleAspectFit
    imageView.layer.cornerRadius = 2
    imageView.clipsToBounds = true
    return imageView
  }()

  // MARK: - Action

  func update(image: UIImage) {
    imageView.image = image
  }
}
