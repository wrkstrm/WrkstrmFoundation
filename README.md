# WrkstrmFoundation

 [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fwrkstrm%2FWrkstrmFoundation%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/wrkstrm/WrkstrmFoundation)
 [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fwrkstrm%2FWrkstrmFoundation%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/wrkstrm/WrkstrmFoundation)

This package is compatible with Linux.

Swift essentials for JSON, data archiving, and networking

WrkstrmFoundation now ships with two libraries:

### WrkstrmFoundation

A collection of Swift extensions and utilities tailored for efficient JSON handling and robust data archiving. This module offers:

- JSON Processing: Customizable `JSONDecoder` and `JSONEncoder` extensions equipped with versatile date handling strategies for managing diverse data formats.
- Data Archiving and Retrieval: Implementations of `CodableArchiver`, a flexible and type-safe struct for archiving and retrieving `Codable` objects, including support for file management tasks.
- Platform Compatibility: Special considerations for platform-specific requirements, such as adjustments for Linux environments regarding `DispatchQueue` limitations.
- Logging and Error Handling: Integration of logging mechanisms for error tracking and debugging, ensuring robustness and reliability.
- Custom Swift Extensions: Additional extensions for enhancing standard library functionality, like `String` and `Bundle`, to seamlessly handle tasks such as file path generation and JSON file decoding.

### WrkstrmNetworking

Lightweight networking utilities built on `URLSession` with cURL logging. The module includes request and response types, a JSON client for automatic encoding/decoding, and a configurable rate limiter for outbound requests.

This repository is ideal for Apple platform and Linux developers seeking to enrich their Swift applications with efficient, reliable, and reusable components. Each utility is documented for ease of use, adhering to best coding practices and ensuring seamless integration into various Swift projects.

<!-- START_SECTION:status -->

| Library                            | Build Status                                                                                                                                                                                                                        |
| :--------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| wrkstrm-foundation-tests-swift.yml | [![wrkstrm-foundation-tests-swift.yml](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-tests-swift.yml/badge.svg)](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-tests-swift.yml) |
| wrkstrm-foundation-swift.yml       | [![wrkstrm-foundation-swift.yml](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-swift.yml/badge.svg)](https://github.com/wrkstrm/mono/actions/workflows/wrkstrm-foundation-swift.yml)                   |

---

<!-- END_SECTION:status -->
