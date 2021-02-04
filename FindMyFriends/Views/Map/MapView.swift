import MapKit
import SwiftUI
import ImageFetcher

struct MapView: UIViewRepresentable {
  @Binding
  var annotations: [UserAnnotation]
  let imageFetcher: ImageFetcher
  
  func makeCoordinator() -> MapViewCoordinator {
    MapViewCoordinator(self, imageFetcher: imageFetcher)
  }
  
  func makeUIView(context: Context) -> MKMapView{
    let map = MKMapView(frame: .zero)
    // Default region to frame the real action.
    map.setRegion(initialRegion, animated: false )
    return map
  }
  
  func updateUIView(_ view: MKMapView, context: Context) {
    view.delegate = context.coordinator
    
    guard
      !view.annotations.isEmpty,
      let annotations = view.annotations as? [UserAnnotation]
    else {
      // Requirements don't specify a use case where *new* annotation
      // might need to be shown
      view.addAnnotations(self.annotations)
      return
    }
    
    for updatedAnnotation in self.annotations {
      let annotation =  annotations.first { $0.id == updatedAnnotation.id }
      UIView.animate(withDuration: 0.3) {
        annotation?.subtitle = updatedAnnotation.subtitle
        annotation?.coordinate = updatedAnnotation.coordinate
      }
    }
  }
}

// - Helper initial map region
private let initialRegion = MKCoordinateRegion(
  center: CLLocationCoordinate2D(
    latitude: 56.951,
    longitude: 24.107),
  span: MKCoordinateSpan(
    latitudeDelta: 0.015,
    longitudeDelta: 0.015)
)
