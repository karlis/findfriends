extension Set {
  mutating func updateBy(
    predicate: (Element) -> Bool,
    mutate: (inout Element) -> Void
  ) {
    guard var element = self.first(where: predicate) else { return }

    self.remove(element)
    mutate(&element)
    self.insert(element)
  }
}
