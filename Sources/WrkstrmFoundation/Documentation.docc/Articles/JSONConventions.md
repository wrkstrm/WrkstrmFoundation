# JSON Conventions

- Use explicit `CodingKeys` for wire key mapping. Avoid automatic key-conversion strategies (e.g., snake_case).
- Keep date handling centralized via `JSONDecoder.commonDateParsing` / `JSONEncoder.commonDateFormatting` (WrkstrmFoundation custom strategies).
- Rationale and migration notes: see “SnakeCase considered harmful”.

## On-disk formatting (human-facing JSON)

- Use prettyPrinted + sortedKeys + withoutEscapingSlashes for artifacts intended for humans
  (e.g., agency/agenda/agent triads, reports, indices). Prefer atomic writes.
- Utilities:
  - `JSONFormatting.humanEncoder` — `JSONEncoder` preset for human-readable output.
  - `JSONFormatting.humanOptions` — `JSONSerialization.WritingOptions` preset.
  - `JSONFileWriter.write(_:to:)` and `writeJSONObject(_:to:)` — atomic file helpers.
