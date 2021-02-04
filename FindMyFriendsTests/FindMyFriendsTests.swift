import Combine
import ComposableArchitecture
import XCTest

@testable import Geocoder
@testable import ImageFetcher
@testable import TCPClient

@testable import FindMyFriends

class FindMyFriendsTests: XCTestCase {
  func testUserLoading() {
    let messagePublisher = PassthroughSubject<Message, Never>()

    var connectCalled = false
    var authCalled = false

    // Should not be called in this test flow
    let client = Client(
      messagePublisher: messagePublisher,
      connect: { _, _ in connectCalled = true },
      auth: { _ in authCalled = true },
      close: { messagePublisher.send(completion: .finished) }
    )

    let user = User(
      id: "123",
      name: "Test",
      image: "No",
      location: Location(latitude: 0, longitude: 0)
    )

    let mockAddress = AddressResponse(
      id: "123",
      address: "Pūces iela 2b, Cēsis"
    )

    let geocoder = Geocoder { _, completion in
      completion(mockAddress.address)
    }

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        client: client,
        geocoder: geocoder
      )
    )

    store.assert(
      .send(.loadUsers),
      .do {
        XCTAssertTrue(authCalled)
        XCTAssertTrue(connectCalled)
      },
      .do {
        messagePublisher.send(.userlist([user]))
      },
      .send(.clientResponse(.success(.userlist([user])))) {
        let user = user.user
        $0.users = [user]
      },
      .receive(.handleUser(.success(user))),
      .receive(.geocoded(mockAddress)) {
        $0.users.updateBy(
          predicate: { $0.id == mockAddress.id },
          mutate: { $0.subtitle = mockAddress.address }
        )
      },
      .send(.stop)
    )
  }

  func testGeocode() {

    // Should not be called in this test flow
    let client = Client(
      messagePublisher: PassthroughSubject<Message, Never>(),
      connect: { _, _ in fatalError() },
      auth: { _ in fatalError() },
      close: { fatalError() }
    )

    let user = User(
      id: "123",
      name: "Test",
      image: "No",
      location: Location(latitude: 0, longitude: 0)
    )
    let update = UserUpdate(id: "123", location: Location(latitude: 1, longitude: 1))

    let mockAddress = AddressResponse(
      id: "123",
      address: "Rīgas ielā 21, Cēsis"
    )

    let geocoder = Geocoder { _, completion in
      completion(mockAddress.address)
    }

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        client: client,
        geocoder: geocoder
      )
    )

    store.assert(
      .send(.clientResponse(.success(.userlist([user])))) {
        let user = user.user
        $0.users = [user]
      },
      .receive(.handleUser(.success(user))),
      .receive(.geocoded(mockAddress)) {
        $0.users.updateBy(
          predicate: { $0.id == mockAddress.id },
          mutate: { $0.subtitle = mockAddress.address }
        )
      },
      .send(.clientResponse(.success(.update([update])))),
      .receive(.handleUpdate(.success(update))) {
        $0.users.updateBy(
          predicate: { $0.id == update.id },
          mutate: { $0.location = update.location }
        )
      },
      .receive(.geocoded(mockAddress))
    )
  }
}
