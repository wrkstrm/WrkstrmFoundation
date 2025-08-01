#if os(Linux)
  // Necessary import for Linux due to DispatchQueue not being Sendable.
  @preconcurrency import Foundation
#else
  import Foundation
#endif

/// A struct for archiving (`Codable`) objects using JSON encoding and decoding.
/// It provides methods to save, retrieve, and remove objects from a specified directory.
public struct CodableArchiver<T: Codable> {
  /// The JSON encoder to use for archiving.
  public let encoder: JSONEncoder

  /// The JSON decoder to use for unarchiving.
  public let decoder: JSONDecoder

  /// The file manager instance to handle file operations.
  public let fileManager: FileManager = .default

  /// The directory where the archives are stored.
  public let archiveDirectory: URL

  /// The key used to identify the archive file.
  public let key: AnyHashable

  /// Initializes a new `CodableArchiver` with the given parameters.
  ///
  /// - Parameters:
  ///   - key: A unique key to identify the archive.
  ///   - directory: The directory where the archive will be stored.
  ///   - encoder: A custom `JSONEncoder` for encoding objects. Defaults to `.default`.
  ///   - decoder: A custom `JSONDecoder` for decoding objects. Defaults to `.default`.
  ///   - searchPathDomainMask: The domain mask to use when searching for the directory.
  /// - Throws: `ArchiverError.directoryNotFound` if the directory cannot be located.
  public enum ArchiverError: Error {
    case directoryNotFound
  }

  public init(
    key: AnyHashable,
    directory: FileManager.SearchPathDirectory,
    encoder: JSONEncoder = .default,
    decoder: JSONDecoder = .default,
    searchPathDomainMask: FileManager.SearchPathDomainMask = [.allDomainsMask],
  ) throws {
    self.encoder = encoder
    self.decoder = decoder
    guard
      let archiveDirectory = fileManager.urls(for: directory, in: searchPathDomainMask).first
    else {
      throw ArchiverError.directoryNotFound
    }
    self.archiveDirectory = archiveDirectory.appendingPathComponent(String(key.description))
    self.key = key
  }

  /// Initializes a new `CodableArchiver` with a specific URL for the archive directory.
  ///
  /// - Parameters:
  ///   - directory: The URL of the directory where the archive will be stored.
  ///   - encoder: A custom `JSONEncoder` for encoding objects. Defaults to `.default`.
  ///   - decoder: A custom `JSONDecoder` for decoding objects. Defaults to `.default`.
  public init(
    directory: URL,
    encoder: JSONEncoder = .default,
    decoder: JSONDecoder = .default,
  ) {
    self.encoder = encoder
    self.decoder = decoder
    archiveDirectory = directory.deletingLastPathComponent()
    key = directory.lastPathComponent
  }

  // MARK: - Filemanager helpers

  /// Returns the file path for a given key within the archive directory.
  ///
  /// - Parameter key: The key for which to generate the file path.
  /// - Returns: The file path as a `String`.
  public func filePathForKey(_ key: AnyHashable) -> String {
    archiveDirectory.appendingPathComponent(String(key.description)).path
  }

  // MARK: - Workflow operations

  /// Retrieves and decodes an object of type `T` associated with the given key.
  ///
  /// - Parameter key: The key for the object to retrieve. Defaults to the archiver's key.
  /// - Returns: An optional object of type `T`, if it exists and can be decoded.
  public func get(_ key: AnyHashable? = nil) -> T? {
    guard
      let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePathForKey(key ?? self.key))
        as? Data
    else {
      return nil
    }

    guard let decoded = try? decoder.decode(T.self, from: data) else {
      return nil
    }

    return decoded
  }

  /// Encodes and archives an object of type `T` associated with the given key.
  ///
  /// - Parameters:
  ///   - value: The object to archive.
  ///   - key: The key to associate with the object. Defaults to the archiver's key.
  /// - Returns: A `Bool` indicating success or failure.
  @discardableResult
  public func set(_ value: T, forKey key: AnyHashable? = nil) -> Bool {
    guard let data = try? encoder.encode(value) else {
      return false
    }

    try? fileManager.createDirectory(
      at: archiveDirectory,
      withIntermediateDirectories: true,
      attributes: nil,
    )

    return NSKeyedArchiver.archiveRootObject(data, toFile: filePathForKey(key ?? self.key))
  }

  /// Encodes and archives an array of objects of type `T` associated with the given key.
  ///
  /// - Parameters:
  ///   - value: The array of objects to archive.
  ///   - key: The key to associate with the objects. Default s to the archiver's key.
  /// - Returns: A `Bool` indicating success or failure.
  @discardableResult
  public func set(_ value: [T], forKey key: AnyHashable? = nil) -> Bool {
    guard let encodedValues = try? value.map({ try encoder.encode($0) }) else {
      return false
    }

    try? fileManager.createDirectory(
      at: archiveDirectory,
      withIntermediateDirectories: true,
      attributes: nil,
    )

    return NSKeyedArchiver.archiveRootObject(encodedValues, toFile: filePathForKey(key ?? self.key))
  }

  /// Clears the archive by removing all items in the directory.
  ///
  /// - Throws: An error if the directory cannot be removed.
  public func clear() throws {
    try fileManager.removeItem(at: archiveDirectory)
  }
}
