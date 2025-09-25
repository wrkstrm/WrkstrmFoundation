# Query Parameters (typed helpers)

Building HTTP query strings consistently is deceptively hard. Raw
`URLQueryItem` values are `Optional<String>` and push formatting decisions to
every call site, which leads to drift (e.g., `true` vs `1`, `100` vs `100.0`,
enum case spelling, nil vs absent).

WrkstrmNetworking provides a tiny helper, `HTTP.QueryItems`, that centralizes
these choices so requests remain deterministic and audit‑friendly.

## Goals

- Type‑friendly: accept `Bool`, `Int`, `Double`, `RawRepresentable<String>`, and
  `String` without repeating conversions.
- Clear nil semantics: ignore `nil` instead of emitting bare keys (no `name=` or
  `name` without value) unless you opt‑in.
- Arrays: join common lists (e.g., symbols) with a consistent separator
  (`,` by default).
- Determinism: pair with the existing canonical sorting in
  `HTTP.URLRequestConvertible` so identical inputs yield identical URLs.

## Usage

```swift
// Inside a request initializer
options = .make(headers: ["Content-Type": "application/x-www-form-urlencoded"]) { q in
  q.add("symbol", value: symbol)                  // String
  q.add("quantity", value: quantity)              // Int
  q.add("price", value: price)                    // Double
  q.add("greeks", value: includeGreeks)           // Bool -> "true"/"false"
  q.add("side", value: side)                      // enum RawRepresentable<String>
  q.addJoined("symbols", values: symbols)         // [String] -> "AAPL,TSLA,MSFT"
}
```

The `.make` convenience creates `HTTP.Request.Options` from a builder closure,
leaving header and timeout handling unchanged.

## Do / Don’t

- Do use `q.add(_, value:)` overloads for native types and enums.
- Do use `q.addJoined(_, values:)` for lists that must be comma‑separated.
- Don’t hand‑roll `String(...)` or `joined(separator:)` at call sites.
- Don’t emit bare keys (`name` without `=`) unless the API explicitly requires
  it; the helpers omit nils by default.

## Rationale

`URLQueryItem` is the transport, not policy. Centralizing conversions avoids
footguns, makes cache keys and tests stable, and is a step toward L3 typed
invocations where options are validated before dispatch.
