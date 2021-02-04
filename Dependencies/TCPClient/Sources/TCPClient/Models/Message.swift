public enum Message: Equatable {
  case userlist([User])
  case update([UserUpdate])
}
