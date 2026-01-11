# JSON Defaults Overview

WrkstrmFoundation supplies Foundation‑backed JSON defaults that complement the portable contracts in WrkstrmMain.

## Encoders And Decoders

Use the common presets to standardize date handling across your app:

```swift
import Foundation
import WrkstrmFoundation

let encoder = JSONEncoder.commonDateFormatting
let decoder = JSONDecoder.commonDateParsing
```

These presets support ISO‑8601 (with/without fractional seconds) and numeric epochs (seconds or ms), and are designed to survive typical API quirks.

## Composing A Parser

Bridge to WrkstrmMain’s portable `JSON.Parser` using these defaults:

```swift
import WrkstrmFoundation

let parser = JSON.Parser.foundationDefault
```
