import ComposableArchitecture
import SwiftUI
import Combine
import ImageFetcher
import Geocoder
import TCPClient

struct AppState: Equatable {
  var users: Set<User> = []
}

enum AppAction: Equatable {
  case loadUsers
  case clientResponse(Result<Message, Never>)
  case handleUser(Result<TCPClient.User, Never>)
  case handleUpdate(Result<UserUpdate, Never>)
  case geocoded(AddressResponse)

  case stop
}

struct AppEnvironment {
  var client: Client
  var geocoder: Geocoder
}

private let user = "karlis@lukstins.com"

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
    case .loadUsers:
      environment.client.connect("​find.lukstins.lv", 6111)
      environment.client.auth(user)
      return environment.client.messagePublisher
        .receive(on: DispatchQueue.main)
        .catchToEffect()
        .cancellable(id: LoadUsers())
        .map(AppAction.clientResponse)

    case let .clientResponse(.success(.userlist(users))):
      state.users = Set(users.map(\.user))

      return Publishers.Sequence(sequence: users)
        .setFailureType(to: Never.self)
        .eraseToAnyPublisher()
        .catchToEffect()
        .map(AppAction.handleUser)

    case let .handleUser(.success(user)):
      guard let annotation = state.users.first(where: { $0.id == user.id })
      else { return .none }

      return .future { callback in
        environment.geocoder.reverseGeocodeLocation(
          user.location.clLocation,
          { address in
            let response = AddressResponse(id: user.id, address: address)
            callback(.success(AppAction.geocoded(response)))
          }
        )
      }

    case let .clientResponse(.success(.update(updates))):
      return Publishers.Sequence(sequence: updates)
        .setFailureType(to: Never.self)
        .eraseToAnyPublisher()
        .catchToEffect()
        .map(AppAction.handleUpdate)

    case let .handleUpdate(.success(update)):
      state.users.updateBy(
        predicate: { $0.id == update.id },
        mutate: { $0.location = update.location }
      )

      return .future { callback in
        environment.geocoder.reverseGeocodeLocation(
          update.location.clLocation,
          { address in
            let response = AddressResponse(id: update.id, address: address)
            callback(.success(AppAction.geocoded(response)))
          }
        )
      }

    case let .geocoded(response):
      state.users.updateBy(
        predicate: { $0.id == response.id },
        mutate: { $0.subtitle = response.address }
      )
      return .none

    case .stop:
      environment.client.close()
      return .cancel(id: LoadUsers())
  }
}

struct LoadUsers: Hashable {}

struct AddressResponse: Equatable {
  let id: String
  let address: String?
}
