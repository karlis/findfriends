import MapKit
import Combine
import ImageFetcher
import Geocoder

class MapViewCoordinator: NSObject, MKMapViewDelegate {
  var mapViewController: MapView
  private let imageFetcher: ImageFetcher
  var disposeBag = [AnyCancellable]()
  
  init(
    _ control: MapView,
    imageFetcher: ImageFetcher
  ) {
    self.imageFetcher = imageFetcher
    self.mapViewController = control
  }
  
  func mapView(
    _ mapView: MKMapView, viewFor
      annotation: MKAnnotation
  ) -> MKAnnotationView? {
    guard let annotation = annotation as? UserAnnotation else { return nil }
    let annotationView = mapView.dequeueReusableAnnotationView(
      withIdentifier: UserAnnotationView.identifier
    ) as? UserAnnotationView ?? UserAnnotationView(annotation: annotation)
    
    // TODO:
    // Move imageFetcher to appReducer just like we use Geocoder.
    guard
      let urlString = annotation.imageUrl,
      let url = URL(string: urlString)
    else { return annotationView }
    
    imageFetcher
      .fetch(url)
      .compactMap { UIImage(data: $0) }
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { _ in }, // TODO: handle completion
        receiveValue: { annotationView.update(image: $0) }
      )
      .store(in: &disposeBag)
    
    return annotationView
  }
}


