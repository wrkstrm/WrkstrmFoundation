# JSON Conventions

- Use explicit `CodingKeys` for wire key mapping. Avoid automatic key-conversion strategies (e.g., snake_case).
- Keep date handling centralized via `JSONDecoder.commonDateParsing` / `JSONEncoder.commonDateFormatting` (WrkstrmFoundation custom strategies).
- Rationale and migration notes: see “SnakeCase considered harmful”.

## On-disk Formatting (Human-facing JSON)

- Use prettyPrinted + sortedKeys + withoutEscapingSlashes for artifacts intended for humans
  (e.g., agency/agenda/agent triads, reports, indices). Prefer atomic writes.
- Utilities:
  - `JSON.Formatting.humanEncoder` — `JSONEncoder` preset for human-readable output.
  - `JSON.Formatting.humanOptions` — `JSONSerialization.WritingOptions` preset.
  - `JSON.FileWriter.write(_:to:)` and `writeJSONObject(_:to:)` — atomic file helpers.
  - NDJSON (one object per line): `JSON.NDJSON.encodeLine(_:)` for in-memory use and
    `JSON.NDJSON.appendLine(_:,to:)` / `appendJSONObjectLine(_:,to:)` to append to files.
    Lines end with exactly one trailing newline and string newlines are escaped (`\n`).
  - Writers must end files with exactly one trailing newline (no extra blank line).
