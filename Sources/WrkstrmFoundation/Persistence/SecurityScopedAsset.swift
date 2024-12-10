import Foundation

/// A structure representing a security-scoped asset with its file path and associated bookmark
/// data.
///
/// Security-scoped bookmarks allow an app to retain access permissions to files and directories
/// selected by the user, even after the app is relaunched. This structure pairs the asset's path
/// with its bookmark data for persistent storage and later retrieval.
///
/// Example usage:
/// ```swift
/// // Create a bookmark for a user-selected file
/// let fileURL = // ... URL from file picker
/// let bookmark = try fileURL.bookmarkData(options: .withSecurityScope)
/// let asset = SecurityScopedAsset(path: fileURL, bookmarkData: bookmark)
///
/// // Later, restore access using the asset
/// var isStale = false
/// let url = try URL(resolvingBookmarkData: asset.bookmarkData,
///                   options: .withSecurityScope,
///                   relativeTo: nil,
///                   bookmarkDataIsStale: &isStale)
/// guard url.startAccessingSecurityScopedResource() else {
///     throw SomeError.accessDenied
/// }
/// defer { url.stopAccessingSecurityScopedResource() }
/// ```
///
/// - Note: Security-scoped bookmarks are essential for maintaining file access across app launches
///         when working with files outside the app's sandbox.
public struct SecurityScopedAsset: Codable {
  /// The file system URL representing the asset's location.
  ///
  /// This URL points to the original location of the security-scoped resource. Note that the
  /// actual file or directory might have moved since the bookmark was created, in which case
  /// the bookmark data should be used to resolve the current location.
  public let path: URL

  /// The security-scoped bookmark data for the asset.
  ///
  /// This data allows the app to regain access to the resource in future launches. It should
  /// be created using `URL.bookmarkData(options:)` with the `.withSecurityScope` option.
  public let bookmarkData: Data

  /// Creates a new security-scoped asset with the specified path and bookmark data.
  ///
  /// - Parameters:
  ///   - path: The URL path to the asset
  ///   - bookmarkData: The security-scoped bookmark data that grants access to the asset
  ///
  /// - Note: The bookmark data should be created with security scope options appropriate
  ///         for your use case, typically `.withSecurityScope`.
  public init(path: URL, bookmarkData: Data) {
    self.path = path
    self.bookmarkData = bookmarkData
  }
}
