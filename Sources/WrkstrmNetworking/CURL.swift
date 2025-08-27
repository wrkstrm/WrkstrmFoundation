import Foundation
import WrkstrmLog

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A utility for rendering `URLRequest` instances as copy-pasteable cURL commands.
///
/// `CURL` produces commands that faithfully mirror HTTP method, headers,
/// URL (with selective redaction), and body. It is intended for debugging,
/// incident analysis, and reproducible bug reports.
///
/// - Important: `printCURLCommand` emits logs only in `DEBUG` builds.
/// - Thread Safety: All APIs are pure and stateless.
/// - Security: Standard sensitive headers and query parameters are redacted.
///   Extend the redaction lists to match your environment.
/// - SeeAlso: ``command(from:in:)``, ``printCURLCommand(from:in:)``
public enum CURL {
  // MARK: Redaction rules

  /// Case-insensitive header names to redact from logs.
  ///
  /// Defaults: `Authorization`, `X-API-Key`, `API-Key`, `X-Auth-Token`, `Cookie`.
  private static let sensitiveHeaders: Set<String> = [
    "authorization", "x-api-key", "api-key", "x-auth-token", "cookie",
  ]

  /// Case-insensitive query parameter names to redact from URLs.
  ///
  /// Defaults: `access_token`, `token`, `api_key`, `apikey`, `key`.
  private static let sensitiveQueryKeys: Set<String> = [
    "access_token", "token", "api_key", "apikey", "key",
  ]

  // MARK: Helpers

  /// Shell-quotes a string for POSIX shells using single quotes.
  ///
  /// Any single quote characters are escaped using the portable
  /// `'\''` pattern so the resulting token can be safely pasted into
  /// a shell command.
  ///
  /// - Parameter s: The raw string to quote.
  /// - Returns: A single-quoted, shell-safe representation of `s`.
  private static func shQuote(_ s: String) -> String {
    // If it already looks single-quoted, leave it; otherwise wrap and escape
    let escaped = s.replacingOccurrences(of: "'", with: "'\\''")
    return "'\(escaped)'"
  }

  /// Extracts headers from a request as a stable, case-insensitive list.
  ///
  /// - Parameter req: The request to inspect.
  /// - Returns: Header name/value pairs sorted by lowercased header name.
  private static func requestHeaders(_ req: URLRequest) -> [(String, String)] {
    (req.allHTTPHeaderFields ?? [:])
      .map { ($0.key, $0.value) }
      .sorted { $0.0.lowercased() < $1.0.lowercased() }
  }

  /// Redacts a header value if the header name is marked sensitive.
  ///
  /// - Parameters:
  ///   - name: Header name (any casing).
  ///   - value: Original header value.
  /// - Returns: `"[REDACTED]"` for sensitive headers; otherwise `value`.
  private static func redactHeaderIfNeeded(name: String, value: String)
    -> String
  {
    Self.sensitiveHeaders.contains(name.lowercased()) ? "[REDACTED]" : value
  }

  /// Redacts sensitive query parameters within a URL.
  ///
  /// If the URL has a query string, any parameters whose names match
  /// ``sensitiveQueryKeys`` (case-insensitive) are replaced with the literal
  /// `"[REDACTED]"`. Structure and non-sensitive parameters are preserved.
  ///
  /// - Parameter url: The original URL.
  /// - Returns: A string form of the URL with sensitive query parameters redacted.
  private static func redactURL(_ url: URL) -> String {
    guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let items = comps.queryItems, !items.isEmpty
    else {
      return url.absoluteString
    }
    comps.queryItems = items.map { item in
      if Self.sensitiveQueryKeys.contains(item.name.lowercased()) {
        return URLQueryItem(name: item.name, value: "[REDACTED]")
      }
      return item
    }
    return comps.string ?? url.absoluteString
  }

  // MARK: Public API

  /// Builds a copy-pasteable cURL command that reproduces the given request.
  ///
  /// The command includes:
  /// - `-X` with the HTTP method
  /// - `-H` lines for each header (with sensitive values redacted)
  /// - The URL (with sensitive query parameters redacted)
  /// - Body data
  ///   - UTF-8 bodies emitted via `-d '…'`
  ///   - Non-UTF-8 bodies emitted via `--data-binary '<N bytes binary body>'`
  ///   - Streamed bodies emitted via `--data-binary '<streamed body>'`
  ///
  /// - Note: The `environment` parameter is accepted for parity with
  ///   the logging variant and future extension points; it does not
  ///   alter the produced command.
  ///
  /// - Parameters:
  ///   - request: The `URLRequest` to render.
  ///   - environment: Networking environment metadata.
  /// - Returns: A complete cURL command string.
  public static func command(from request: URLRequest, in _: HTTP.Environment)
    -> String
  {
    var parts: [String] = ["curl"]

    // Method
    let method = request.httpMethod ?? "GET"
    parts += ["-X", shQuote(method)]

    // Headers (from the actual URLRequest)
    for (name, value) in requestHeaders(request) {
      let redacted = redactHeaderIfNeeded(name: name, value: value)
      parts += ["-H", shQuote("\(name): \(redacted)")]
    }

    // URL (with sensitive query params redacted)
    if let url = request.url {
      parts.append(shQuote(redactURL(url)))
    }

    // Body
    if let body = request.httpBody, !body.isEmpty {
      if let asUTF8 = String(data: body, encoding: .utf8) {
        // Text-ish body: show as -d '...'
        parts += ["-d", shQuote(asUTF8)]
      } else {
        // Binary body: do not dump raw bytes into logs
        parts += [
          "--data-binary", shQuote("<\(body.count) bytes binary body>"),
        ]
      }
    } else if let stream = request.httpBodyStream {
      // Streaming body; cannot read safely here
      _ = stream  // silence linter
      parts += ["--data-binary", shQuote("<streamed body>")]
    }

    return parts.joined(separator: " ")
  }

  /// Logs an equivalent cURL command for the given request in `DEBUG` builds.
  ///
  /// This is a convenience wrapper over ``command(from:in:)`` that also
  /// performs a secondary redaction pass for legacy callers that may have set
  /// authorization headers only on the `environment`.
  ///
  /// - Parameters:
  ///   - request: The `URLRequest` to render.
  ///   - environment: Networking environment metadata (used for legacy header masking).
  ///
  /// - Important: This function is a no-op in non-`DEBUG` builds.
  public static func printCURLCommand(
    from request: URLRequest,
    in environment: HTTP.Environment
  ) {
    #if DEBUG
      var command = command(from: request, in: environment)

      // Also mask any Authorization that slipped through older callers that only set env headers
      for (name, value) in environment.headers
      where name.caseInsensitiveCompare("Authorization") == .orderedSame {
        let raw = "-H 'Authorization: \(value)'"
        let red = "-H 'Authorization: [REDACTED]'"
        command = command.replacingOccurrences(of: raw, with: red)
      }

      Log.networking.info(
        """
        Creating request with the equivalent cURL command:
        ➖➖➖➖🌀 cURL command 🌀➖➖➖➖
        \(command)
        🌀➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖🌀
        """
      )
    #endif  // DEBUG
  }
}
