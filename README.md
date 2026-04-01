# Ignore

A Swift package for checking file paths against gitignore-style rule files. Under the hood it calls into ripgrep's Rust gitignore parser via [swift-bridge](https://github.com/nickel-org/swift-bridge), shipped as a pre-built universal xcframework (arm64 + x86_64, macOS).

Parsed ignore files are cached by path, so the second check against the same file is just a pattern match with no disk I/O.

## Installation

Add the package as a local dependency or drag the `Ignore` folder into your Xcode project.

```swift
.package(path: "path/to/Ignore")
```

To rebuild from source, run `build.sh` from the parent directory. You'll need a Rust toolchain and `swift-bridge-cli`.

## Usage

```swift
import Ignore
```

### Single path

`String`, `URL`, and `FilePath` (macOS 12+) all have an `isIgnored(in:)` method. The `in` parameter is a path to any gitignore-formatted file.

```swift
"/Users/me/project/.build/debug".isIgnored(in: "/Users/me/project/.gitignore")
// true

let file = URL(fileURLWithPath: "/Users/me/project/src/main.swift")
file.isIgnored(in: "/Users/me/project/.gitignore")

let fp = FilePath("/Users/me/project/node_modules/leftpad")
fp.isIgnored(in: "/Users/me/project/.gitignore")
```

### Cache busting

Since ignore files are cached by path, edits to the file on disk won't be picked up automatically. Two ways to force a re-read:

```swift
// Re-read just this one ignore file on the next check
path.isIgnored(in: ignoreFile, bustCache: true)

// Or nuke the whole cache (all ignore files)
bust_gitignore_cache()
```

### Batch checking

When you have a list of paths to check against the same ignore file, the batch methods are faster than looping `isIgnored`. They cross the Swift/Rust boundary once and take the cache lock once.

`filterIgnored` returns only the non-ignored paths:

```swift
let paths = [
    "/Users/me/project/.build/debug",
    "/Users/me/project/src/main.swift",
    "/Users/me/project/.DS_Store",
]
let kept = paths.filterIgnored(in: "/Users/me/project/.gitignore")
// ["/Users/me/project/src/main.swift"]
```

`checkIgnored` returns a `[Bool]` aligned with the input (`true` = ignored):

```swift
let ignored = paths.checkIgnored(in: "/Users/me/project/.gitignore")
// [true, false, true]
```

Both work on `[URL]` and `[FilePath]` sequences too:

```swift
let urls: [URL] = getFileURLs()
urls.filterIgnored(in: gitignorePath)   // -> [URL]
urls.checkIgnored(in: gitignorePath)    // -> [Bool]

let filePaths: [FilePath] = getFilePaths() // macOS 12+
filePaths.filterIgnored(in: gitignorePath) // -> [FilePath]
```

The `separator` parameter (default `"\n"`) controls how paths are joined before crossing FFI. Pick something that won't appear in your paths. `bustCache` works the same as the single-path version.

```swift
paths.filterIgnored(in: ignoreFile, separator: "\n", bustCache: true)
```

## API

### On `String`, `URL`, `FilePath`

- `isIgnored(in:bustCache:) -> Bool` - check one path against an ignore file

### On `Sequence<String>`, `Sequence<URL>`, `Sequence<FilePath>`

- `filterIgnored(in:separator:bustCache:) -> [Element]` - batch check, returns non-ignored paths
- `checkIgnored(in:separator:bustCache:) -> [Bool]` - batch check, returns one bool per input path (`true` = ignored)

### Free functions

- `bust_gitignore_cache()` - drop all cached ignore file data
- `check_if_ignored(_:_:_:) -> Bool` - low-level single check (path, ignoreFile, bustCache)
- `check_if_ignored_batch(_:_:_:_:) -> RustString` - low-level batch check (paths, ignoreFile, separator, bustCache); returns `"1"`/`"0"` joined by the separator

## Building from source

From `crates/ignore`:

```bash
./build.sh release
```

This builds the Rust library for both x86_64 and aarch64, creates a universal binary with `lipo`, and packages it into the xcframework with `swift-bridge-cli`. Requires Rust, `swift-bridge-cli`, and `swiftformat`.
