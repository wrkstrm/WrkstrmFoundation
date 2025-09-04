# JSON Conventions

- Use explicit `CodingKeys` for wire key mapping. Avoid automatic key-conversion strategies (e.g., snake_case).
- Keep date handling centralized via `JSONDecoder.commonDateParsing` / `JSONEncoder.commonDateFormatting` (WrkstrmFoundation custom strategies).
- Rationale and migration notes: see “SnakeCase considered harmful”.
