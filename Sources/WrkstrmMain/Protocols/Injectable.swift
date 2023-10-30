public protocol Injectable {
  associatedtype Resource

  func inject(_ resource: Resource)

  func assertDependencies()
}
