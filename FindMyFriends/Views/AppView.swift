import ComposableArchitecture
import SwiftUI
import ImageFetcher
import Geocoder
import TCPClient

struct AppView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      MapView(
        annotations: viewStore.binding(
          get: { $0.users.map(\.annotation) },
          send: AppAction.loadUsers
        ),
        imageFetcher: .live
      )
      .onAppear {
        viewStore.send(.loadUsers)
      }
      .edgesIgnoringSafeArea(.all)
    }
  }
}

// MARK: - Preview

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(
          client: Client.mock,
          geocoder: Geocoder.mock
        )
      )
    )
  }
}
