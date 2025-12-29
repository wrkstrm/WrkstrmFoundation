# Form URL Encoding in Swift

Learn how to build query strings and `application/x-www-form-urlencoded` request bodies in Swift
without hand-rolling percent-encoding.

@Metadata { @DisplayName("Form URL Encoding in Swift") @TechnologyRoot @PageKind(tutorial) }

@Introduction { Avoid stringly-typed disasters. This tutorial shows how to use `URLComponents`,
`URLQueryItem`, and small helpers to construct query parameters and form-encoded bodies safely,
predictably, and testably — no manual `%` escapes required. }

@LearningPath {

- Understand when to use query parameters vs form bodies
- Build URLs with `URLComponents` and `URLQueryItem`
- Create form-encoded bodies using the same machinery
- Handle arrays, optionals, and special characters
- Verify requests with a copy-pasteable cURL command }

@Prerequisites {

- Basic Swift and `URLRequest`
- Familiarity with HTTP methods and headers }

---

## Step 1: Build query parameters with `URLComponents`

Use `URLComponents` and `URLQueryItem` to attach query parameters. Do **not** concatenate strings.

### Code

```swift
/// Builds a URL by appending query parameters using URLComponents.
/// - Parameters:
///   - base: e.g. https://api.example.com/v1/search
///   - query: key/value pairs; values may be nil to omit.
/// - Returns: A fully-formed URL with percent-encoded query.
func makeURL(base: String, query: [String: String?]) -> URL? {
  guard var comps = URLComponents(string: base) else { return nil }
  let items =
    query
    .compactMap { key, value -> URLQueryItem? in
      guard let value else { return nil }  // omit nils
      return URLQueryItem(name: key, value: value)
    }
    .sorted { $0.name < $1.name }  // canonical ordering aids caching
  comps.queryItems = items.isEmpty ? nil : items
  return comps.url
}

// Example:
let url = makeURL(
  base: "https://api.example.com/v1/search",
  query: [
    "q": "spicy tacos & salsa",
    "limit": "25",
    "lang": "en-US",
  ]
)
// => https://api.example.com/v1/search?lang=en-US&limit=25&q=spicy%20tacos%20%26%20salsa
```

### Why this works

`URLQueryItem` handles percent-encoding for you. You don’t escape ampersands, spaces, or unicode;
you just pass strings and let Foundation serialize correctly.

> Tip: Sorting query items produces a canonical URL that plays nicer with caches and observability
> tooling.

---

## Step 2: Encode a `application/x-www-form-urlencoded` body

Many APIs expect form bodies for POST/PUT. You can reuse `URLComponents` to generate the exact same
`key=value&key2=value2` wire format. WrkstrmNetworking's `HTTP.Request.Encodable` helpers handle
this automatically. When you call `URLRequestConvertible/asURLRequest(with:encoder:)` with a
`[String: String]` body and set `HTTP.Request.Options/headers` to include
`Content-Type: application/x-www-form-urlencoded`, the body is percent-encoded for you.

### Code

```swift
/// Encodes a dictionary as application/x-www-form-urlencoded data.
func formURLEncode(_ params: [String: String]) -> Data? {
  var comps = URLComponents()
  comps.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
  guard let q = comps.percentEncodedQuery else { return nil }
  return Data(q.utf8)
}

func makeFormRequest(url: URL, params: [String: String]) -> URLRequest {
  var req = URLRequest(url: url)
  req.httpMethod = "POST"
  req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
  req.setValue("application/json", forHTTPHeaderField: "Accept")
  req.httpBody = formURLEncode(params)
  return req
}

// Example:
let postURL = URL(string: "https://api.example.com/v1/watchlists/indexes/symbols")!
let req = makeFormRequest(url: postURL, params: ["symbols": "AAPL,IBM,NFLX"])
```

### Why reuse `URLComponents`?

It guarantees identical percent-encoding rules for both query strings and form bodies, preventing
subtle mismatches like double-encoding `%25` or leaving a `+` unescaped.

---

## Step 3: Support arrays and optionals cleanly

APIs commonly accept comma-delimited arrays or repeated keys. Handle both patterns without manual
escaping.

### Code

```swift
/// Joins an array with a delimiter after trimming empties; returns nil if final is empty.
func joinedOrNil(_ values: [String], separator: String = ",") -> String? {
  let trimmed = values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }
  return trimmed.isEmpty ? nil : trimmed.joined(separator: separator)
}

/// Builds query items from heterogeneous inputs.
func queryItems(
  scalars: [String: String?] = [:],
  arrays: [String: [String]] = [:],  // comma-delimited
  repeated: [String: [String]] = [:]  // repeated keys: ?tag=a&tag=b
) -> [URLQueryItem] {
  var items: [URLQueryItem] = []

  for (k, v) in scalars {
    if let v { items.append(.init(name: k, value: v)) }
  }
  for (k, vs) in arrays {
    if let joined = joinedOrNil(vs) { items.append(.init(name: k, value: joined)) }
  }
  for (k, vs) in repeated {
    items.append(contentsOf: vs.map { .init(name: k, value: $0) })
  }

  return items
}
```

You can feed these items into either a URL’s `queryItems` or a form body via `percentEncodedQuery`.

---

## Step 4: Build `URLRequest` the right way (content-type aware)

Switch encoding strategy based on `Content-Type`, and never encode twice.

### Code

```swift
/// Content-type aware body encoding.
func applyBody(_ body: Any, to request: inout URLRequest) throws {
  let contentType = request.value(forHTTPHeaderField: "Content-Type")?.lowercased()

  switch contentType {
  case "application/x-www-form-urlencoded":
    if let dict = body as? [String: String] {
      request.httpBody = formURLEncode(dict)
    } else if let items = body as? [URLQueryItem] {
      var c = URLComponents()
      c.queryItems = items
      request.httpBody = c.percentEncodedQuery.flatMap { Data($0.utf8) }
    } else if let s = body as? String {
      request.httpBody = Data(s.utf8)  // pre-encoded string
    } else if let data = body as? Data {
      request.httpBody = data
    } else {
      throw EncodingError.invalidValue(
        body, .init(codingPath: [], debugDescription: "Unsupported form body type"))
    }

  case "application/json", .none:
    let enc = JSONEncoder()
    if contentType == nil {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    request.httpBody = try enc.encode(AnyEncodable(body))

  default:
    if let data = body as? Data {
      request.httpBody = data
    } else if let s = body as? String {
      request.httpBody = Data(s.utf8)
    } else {
      throw EncodingError.invalidValue(
        body,
        .init(codingPath: [], debugDescription: "Unsupported body for \(contentType ?? "unknown")"))
    }
  }
}

/// Type-erased Encodable wrapper for convenience.
struct AnyEncodable: Encodable {
  private let encodeFunc: (Encoder) throws -> Void
  init(_ wrapped: Any) {
    if let e = wrapped as? Encodable {
      self.encodeFunc = e.encode
    } else {
      self.encodeFunc = { _ in
        throw EncodingError.invalidValue(
          wrapped, .init(codingPath: [], debugDescription: "Not Encodable"))
      }
    }
  }
  func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
```

> Note: Don’t peek into the request and re-encode after you’ve already set the body. Double-writes
> are a common cause of “why is the server ignoring me?”

---

## Step 5: Verify with a cURL mirror

Being able to reproduce a request as a cURL command is the best debugging tool you aren’t using
enough.

### Code

```swift
// WrkstrmNetworking includes ``CURL`` for rendering requests.
let command = CURL.command(from: request, in: environment)
print(command)
```

The `CURL` utility mirrors HTTP method, headers, URL, and body, so you can paste the output into a
terminal to confirm exactly what the server receives.

---

## Common pitfalls and how to avoid them

- **Manual percent-encoding:** Don’t. Let `URLQueryItem` do its job.

---

## See also

- Custom backends and URLSession defaults: [Custom Transports](CustomTransport.md)
- **Double-encoding:** If you see `%2520` in logs, you encoded twice. Encode once at the very end.
- **Spaces vs plus:** `URLComponents` will percent-encode spaces as `%20`. Most servers accept both
  `%20` and `+` for `x-www-form-urlencoded`. Do not manually replace spaces with `+` unless your
  server explicitly requires it.
- **Empty values:** Omit keys with `nil` values unless the API requires `key=` to mean “clear this.”
  Be intentional.
- **Arrays:** Check your API contract. Use comma-delimited (`tags=a,b,c`) or repeated keys
  (`tag=a&tag=b&tag=c`) as required. Support both on your side with helpers.

---

## Worked example: Add a symbol to a watchlist (form body)

```swift
struct AddSymbolsRequest {
  let base = "https://api.tradier.com/v1"
  let id: String
  let symbols: [String]

  func build() -> URLRequest? {
    guard let url = URL(string: "\(base)/watchlists/\(id)/symbols") else { return nil }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    req.setValue("application/json", forHTTPHeaderField: "Accept")

    let body: [String: String] = ["symbols": symbols.joined(separator: ",")]
    req.httpBody = formURLEncode(body)
    return req
  }
}

// Usage:
let add = AddSymbolsRequest(id: "indexes", symbols: ["QQQ"])
let request = add.build()!
print(curlCommand(from: request))
```

This produces:

```
curl -X 'POST' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Accept: application/json' \
  'https://api.tradier.com/v1/watchlists/indexes/symbols' \
  -d 'symbols=QQQ'
```

---

## Reference

- ``URLComponents`` — parses and serializes URLs and queries
- ``URLQueryItem`` — type-safe query elements with automatic encoding
- ``URLRequest`` — HTTP method, headers, and body
- MIME type `application/x-www-form-urlencoded` — HTML forms and many REST endpoints

@Links {

- [https://developer.apple.com/documentation/foundation/urlcomponents](https://developer.apple.com/documentation/foundation/urlcomponents)
- [https://developer.apple.com/documentation/foundation/urlqueryitem](https://developer.apple.com/documentation/foundation/urlqueryitem)
- [https://developer.apple.com/documentation/foundation/urlrequest](https://developer.apple.com/documentation/foundation/urlrequest)
  }

@NextSteps {

- Add unit tests that snapshot the resulting URLs and bodies
- Extend helpers to support nested parameters if your backend expects them
- Integrate a cURL logger in DEBUG to reproduce requests during incidents }

```

```
