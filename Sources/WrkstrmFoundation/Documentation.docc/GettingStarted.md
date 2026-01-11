# Getting Started With WrkstrmFoundation

WrkstrmFoundation provides Foundation‑coupled defaults that complement WrkstrmMain’s portable contracts.

## JSON Encoder/Decoder Defaults

```swift
import Foundation
import WrkstrmFoundation

let encoder = JSONEncoder.commonDateFormatting
let decoder = JSONDecoder.commonDateParsing

struct Model: Codable { let when: Date }
let data = try encoder.encode(Model(when: Date()))
let model = try decoder.decode(Model.self, from: data)
```

## CodableArchiver

```swift
import Foundation
import WrkstrmFoundation

struct Preferences: Codable { var theme: String }
let archive = CodableArchiver<Preferences>(directory: URL(fileURLWithPath: NSTemporaryDirectory()))

try archive.save(Preferences(theme: "dark"), for: "prefs")
let loaded: Preferences? = archive.get("prefs")
```

## Networking: Pluggable JSON Coding

```swift
import WrkstrmFoundation

let parser = JSON.Parser.foundationDefault
let client = HTTP.CodableClient(environment: .init(host: "api.example.com"), parser: parser)
```
