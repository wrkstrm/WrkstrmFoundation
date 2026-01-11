# Newline Discipline (On‑disk JSON and NDJSON)

Human‑facing JSON and NDJSON artifacts should end with exactly one trailing newline ("\n"). This
keeps diffs stable, aligns with POSIX tooling expectations, and makes line‑oriented processing
reliable.

## Data Helpers

WrkstrmFoundation provides a tiny extension on `Data` to enforce newline discipline:

```swift
import WrkstrmFoundation

let original = Data([0x41])  // "A"
let normalized = original.ensuringTrailingNewline()  // "A\n"

var mutable = Data()
mutable.ensureTrailingNewlineInPlace()  // now "\n"
```

- `ensuringTrailingNewline()` returns a copy that ends with exactly one newline. Empty input becomes
  a single newline. If the data already ends with "\n", it is returned unchanged.
- `ensureTrailingNewlineInPlace()` is the mutating variant.

## JSON Writers and NDJSON

These helpers are used by WrkstrmFoundation’s JSON writers:

- `JSON.FileWriter.write(_:to:)` and `writeJSONObject(_:to:)` append a single trailing newline when
  `newlineAtEOF` is `true` (default) to keep artifacts tidy.
- `JSON.NDJSON.encodeLine(_:)` and `appendLine(_:,to:)` always produce a single JSON object per line
  terminated by a newline. Embedded string newlines (e.g., "hello\nworld") remain escaped ("\\n"),
  so each record stays on one physical line.

### Examples

```swift
// Pretty, sorted, no escaped slashes; ends with a single newline
aStruct.timestamp = Date(timeIntervalSince1970: 0)
try JSON.FileWriter.write(aStruct, to: url, encoder: JSON.Formatting.humanEncoder)

// Single-line NDJSON (sorted keys). Appends to a log file.
try JSON.NDJSON.appendLine(event, to: logURL)
```

## When to Use

- Use `JSON.FileWriter` for human‑readable JSON files (indices, manifests, reports).
- Use `JSON.NDJSON` for log/event streams and CLIs that need to process one record per line.
- Use the `Data` helpers when normalizing outputs from other sources to guarantee newline policy.

## Related

- <doc:JSONConventions>
- <doc:JSONDefaultsOverview>
