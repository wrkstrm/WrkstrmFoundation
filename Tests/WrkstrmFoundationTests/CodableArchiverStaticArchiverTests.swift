import Foundation
import Testing

@testable import WrkstrmFoundation

/// Tests exercising a static `CodableArchiver` stored on a model type.
@Suite("CodableArchiver static archiver tests")
struct CodableArchiverStaticArchiverTests {

  /// Round-trips a single user profile through the static archiver.
  @Test
  @MainActor
  func staticArchiverObjectRoundTrip() throws {
    let profile = TestUserProfile(username: "tester")

    #expect(TestUserProfile.archiver.set(profile))
    let result = TestUserProfile.archiver.get()
    #expect(result == profile)
    try? TestUserProfile.archiver.clear()
  }

  /// Round-trips an array of profiles through the static archiver.
  @Test
  @MainActor
  func staticArchiverArrayRoundTrip() throws {
    let profiles = [
      TestUserProfile(username: "one"),
      TestUserProfile(username: "two"),
    ]

    #expect(TestUserProfile.archiver.set(profiles))

    let path = TestUserProfile.archiver.filePathForKey(TestUserProfile.archiver.key)
    guard let archived = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else {
      #expect(Bool(false))
      return
    }
    let decoded = archived.compactMap {
      try? TestUserProfile.archiver.decoder.decode(TestUserProfile.self, from: $0)
    }
    #expect(decoded == profiles)
    try? TestUserProfile.archiver.clear()
  }
}
