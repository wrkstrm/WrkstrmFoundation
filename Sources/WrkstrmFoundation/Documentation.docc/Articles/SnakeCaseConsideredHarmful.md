# SnakeCase considered harmful

This repository historically used automatic key-conversion strategies (e.g., `JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase` and matching encoders) to translate between wire JSON (snake_case) and Swift properties (camelCase).

While convenient, this approach is implicit and fragile:

- Asymmetry: decoding uses snake_case, encoding defaults drift to camelCase unless explicitly paired — producing incorrect payloads.
- Hidden contracts: types “work” only when the right decoder is supplied; the same model behaves differently with a default decoder.
- Edge cases: acronyms, digits, and mixed conventions (e.g., `e_tag`, `m3u8_url`) convert inconsistently.
- Tooling drift: non-Codable JSON paths (manual dictionaries, third‑party libs) won’t inherit the strategy and silently break.

Policy (effective immediately)

- Prefer explicit `CodingKeys` to map wire keys to Swift properties.
- Keep JSON date strategies centralized (WrkstrmFoundation’s custom date encoder/decoder) via `JSONDecoder.commonDateParsing` and `JSONEncoder.commonDateFormatting`.
- Confine key‑conversion strategies to integration tests only when brevity helps; do not rely on them in shared libraries or production clients.

Migration notes

- Replace `JSONDecoder.snakecase` / `JSONEncoder.snakecase` with `commonDateParsing` / `commonDateFormatting`.
- Add `enum CodingKeys: String, CodingKey` where wire keys are snake_case.
- Add round‑trip tests for representative requests/responses to lock the keying contract.

Date handling

- Continue using WrkstrmFoundation’s custom date strategies (`JSONDecoder.commonDateParsing` / `JSONEncoder.commonDateFormatting`), which handle epoch seconds/millis and ISO8601 variants consistently across decode/encode.
