import Foundation
import WrkstrmFoundation

private let documentDirectory: FileManager.SearchPathDirectory = .documentDirectory

/// Sample profile model that exposes a static archiver using `Self`
/// and the user's document directory.
struct TestUserProfile: Codable, Equatable {
  let username: String
  /// A static archiver used by ``TestUserProfile`` instances for persistence.
  ///
  /// The archiver is created in a closure so we can handle the throwing
  /// initializer and crash immediately if it fails. This keeps the call site
  /// terse while still satisfying Swift's requirement that errors aren't
  /// propagated from global initializers.
  @MainActor static let archiver: CodableArchiver<Self> = {
    do {
      return try CodableArchiver<Self>(
        key: "User.profile",
        directory: documentDirectory
      )
    } catch {
      fatalError("Failed to create archiver: \(error)")
    }
  }()
}
