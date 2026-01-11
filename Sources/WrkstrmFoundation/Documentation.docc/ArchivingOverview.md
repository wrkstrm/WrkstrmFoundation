# Archiving Overview

Persist Codable models using `CodableArchiver`.

## Save And Load

```swift
import Foundation
import WrkstrmFoundation

struct Preferences: Codable { var theme: String }
let dir = URL(fileURLWithPath: NSTemporaryDirectory())
let archive = CodableArchiver<Preferences>(directory: dir)

try archive.save(Preferences(theme: "dark"), for: "prefs")
let loaded: Preferences? = archive.get("prefs")
```

`CodableArchiver` chooses a file path by key and handles Data round‑trips for you.
