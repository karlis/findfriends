import ComposableArchitecture
import Geocoder
import ImageFetcher
import SwiftUI
import TCPClient

@main
struct FindMyFriendsApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment(
            client: .mock,
            geocoder: .live
          )
        )
      )
    }
  }
}
