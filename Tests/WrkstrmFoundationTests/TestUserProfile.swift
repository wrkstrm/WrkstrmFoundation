import Foundation
import WrkstrmFoundation

private let documentDirectory: FileManager.SearchPathDirectory = .documentDirectory

/// Sample profile model that exposes a static archiver using `Self`
/// and the user's document directory.
struct TestUserProfile: Codable, Equatable {
  let username: String
  @MainActor static let archiver = CodableArchiver<Self>(key: "User.profile", directory: documentDirectory)
}
