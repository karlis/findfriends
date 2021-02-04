import Combine

public struct Client {
  public let messagePublisher: PassthroughSubject<Message, Never>
  public var connect: (String, UInt32) -> Void
  public var auth: (String) -> Void
  public var close: () -> Void
}

extension Client {
  public static var live: Self {
    var socket: Socket?
    let publisher = PassthroughSubject<Message, Never>()

    return Self(
      messagePublisher: publisher,
      connect: { host, port in
        socket = Socket.create(host: host, port: port, messagePublisher: publisher)
      },
      auth: {
        socket?.auth(email: $0)
      },
      close: {
        socket?.closeConnection()
      }
    )
  }
}

import Foundation

extension Client {
  public static var mock: Self {
    let publisher = PassthroughSubject<Message, Never>()

    func sendUpates() {
      guard !updates.isEmpty else { return }
      let update = updates.removeFirst()
      publisher.send(.update([update]))

      DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        DispatchQueue.main.async {
          sendUpates()
        }
      }
    }

    return Self(
      messagePublisher: publisher,
      connect: { host, port in
        print("Created connection to \(host):\(port)")
      },
      auth: { email in
        print("Authenticated \(email)")

        DispatchQueue.main.async {
          publisher.send(.userlist(testUsers))
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
          sendUpates()
        }
      },
      close: {
        print("Close connection")
      }
    )
  }
}

private let testUsers = [
  User(
    id: "101",
    name: "Jānis Bērziņš",
    image: "https://i4.ifrype.com/profile/000/324/v1559116100/ngm_324.jpg",
    location: Location(latitude: 56.9495677035, longitude: 24.1064071655)
  ),
  User(
    id: "102",
    name: "Pēteris Zariņš",
    image: "https://i7.ifrype.com/profile/666/047/v1572553757/ngm_4666047.jpg",
    location: Location(latitude: 56.9503693176, longitude: 24.1084241867)
  ),
]

private var updates = [
  UserUpdate(id: "102", location: Location(latitude: 56.9513288914, longitude: 24.1093254089)),
  UserUpdate(id: "102", location: Location(latitude: 56.9513698483, longitude: 24.1098511219)),
  UserUpdate(id: "102", location: Location(latitude: 56.9513347424, longitude: 24.1103768349)),
  UserUpdate(id: "102", location: Location(latitude: 56.9509836817, longitude: 24.1108596325)),
  UserUpdate(id: "102", location: Location(latitude: 56.9505975112, longitude: 24.1114497185)),
  UserUpdate(id: "102", location: Location(latitude: 56.95043368, longitude: 24.1116642952)),
  UserUpdate(id: "102", location: Location(latitude: 56.9499831407, longitude: 24.111020565)),
  UserUpdate(id: "102", location: Location(latitude: 56.9504453823, longitude: 24.1101408005)),
  UserUpdate(id: "102", location: Location(latitude: 56.9502698482, longitude: 24.1093039513)),
  UserUpdate(id: "102", location: Location(latitude: 56.9503634665, longitude: 24.1084134579)),
  UserUpdate(id: "102", location: Location(latitude: 56.9503693176, longitude: 24.1084241867)),
  UserUpdate(id: "102", location: Location(latitude: 56.9507203841, longitude: 24.1086924076)),
  UserUpdate(id: "102", location: Location(latitude: 56.9509602776, longitude: 24.1089177132)),
  UserUpdate(id: "102", location: Location(latitude: 56.9511299574, longitude: 24.108928442)),
]
