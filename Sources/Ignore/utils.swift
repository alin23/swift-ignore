import Foundation
import System

public extension String {
    func isIgnored(in ignore_file: String, bustCache: Bool = false) -> Bool {
        check_if_ignored(self, ignore_file, bustCache)
    }
    @available(macOS 12, *)
    func isIgnored(in ignore_file: FilePath, bustCache: Bool = false) -> Bool {
        check_if_ignored(self, ignore_file.string, bustCache)
    }
    func isIgnored(in ignore_file: URL, bustCache: Bool = false) -> Bool {
        check_if_ignored(self, ignore_file.path, bustCache)
    }

    /// Match against an ignore file whose patterns are anchored at `root` rather than the file's own
    /// directory. Use when the ignore file lives outside the tree it describes (e.g. a cache dir for an
    /// ignore file that should match paths under `/Applications`).
    func isIgnored(in ignore_file: String, root: String, bustCache: Bool = false) -> Bool {
        check_if_ignored_rooted(self, ignore_file, root, bustCache)
    }
    @available(macOS 12, *)
    func isIgnored(in ignore_file: FilePath, root: String, bustCache: Bool = false) -> Bool {
        check_if_ignored_rooted(self, ignore_file.string, root, bustCache)
    }
}

@available(macOS 12, *)
public extension FilePath {
    func isIgnored(in ignore_file: String, bustCache: Bool = false) -> Bool {
        check_if_ignored(string, ignore_file, bustCache)
    }
    func isIgnored(in ignore_file: FilePath, bustCache: Bool = false) -> Bool {
        check_if_ignored(string, ignore_file.string, bustCache)
    }
    func isIgnored(in ignore_file: URL, bustCache: Bool = false) -> Bool {
        check_if_ignored(string, ignore_file.path, bustCache)
    }
}

public extension URL {
    func isIgnored(in ignore_file: String, bustCache: Bool = false) -> Bool {
        check_if_ignored(path, ignore_file, bustCache)
    }
    @available(macOS 12, *)
    func isIgnored(in ignore_file: FilePath, bustCache: Bool = false) -> Bool {
        check_if_ignored(path, ignore_file.string, bustCache)
    }
    func isIgnored(in ignore_file: URL, bustCache: Bool = false) -> Bool {
        check_if_ignored(path, ignore_file.path, bustCache)
    }
}

public extension String {
    /// Like `isIgnored(in:)`, with the caller saying whether this is a directory, so the path is never statted.
    /// Use it wherever the kind is already known, e.g. while walking a directory tree.
    func isIgnored(in ignore_file: String, isDir: Bool, bustCache: Bool = false) -> Bool {
        check_if_ignored_hinted(self, isDir, ignore_file, bustCache)
    }

    /// Like `isIgnored(in:root:)`, with the caller saying whether this is a directory.
    func isIgnored(in ignore_file: String, root: String, isDir: Bool, bustCache: Bool = false) -> Bool {
        check_if_ignored_rooted_hinted(self, isDir, ignore_file, root, bustCache)
    }
}

/// Checks many paths against one ignore file in a single call, with the caller saying which ones are directories,
/// so none of them is statted. `root` anchors the patterns like `isIgnored(in:root:)`; nil anchors them at the
/// ignore file's directory. Every path must sit under that anchor. Returns one flag per path, in order.
public func checkIgnored(_ paths: [(path: String, isDir: Bool)], in ignoreFile: String, root: String? = nil, bustCache: Bool = false) -> [Bool] {
    guard !paths.isEmpty else { return [] }
    let joined = paths.map(\.path).joined(separator: "\u{0}")
    let kinds = String(paths.map { $0.isDir ? "d" : "f" })
    let result = check_if_ignored_batch_hinted(joined, kinds, ignoreFile, root ?? "", bustCache).toString()
    return result.utf8.map { $0 == UInt8(ascii: "1") }
}

public extension Sequence<String> {
    func checkIgnored(in ignoreFile: String, separator: String = "\n", bustCache: Bool = false) -> [Bool] {
        let joined = joined(separator: separator)
        let result = check_if_ignored_batch(joined, ignoreFile, separator, bustCache)
        return result.toString().split(separator: Character(separator), omittingEmptySubsequences: false).map { $0 == "1" }
    }

    func filterIgnored(in ignoreFile: String, separator: String = "\n", bustCache: Bool = false) -> [Element] {
        let elements = Array(self)
        let ignored = elements.checkIgnored(in: ignoreFile, separator: separator, bustCache: bustCache)
        return zip(elements, ignored).compactMap { $1 ? nil : $0 }
    }
}

public extension Sequence<URL> {
    func checkIgnored(in ignoreFile: String, separator: String = "\n", bustCache: Bool = false) -> [Bool] {
        let joined = map(\.path).joined(separator: separator)
        let result = check_if_ignored_batch(joined, ignoreFile, separator, bustCache)
        return result.toString().split(separator: Character(separator), omittingEmptySubsequences: false).map { $0 == "1" }
    }

    func filterIgnored(in ignoreFile: String, separator: String = "\n", bustCache: Bool = false) -> [Element] {
        let elements = Array(self)
        let ignored = elements.checkIgnored(in: ignoreFile, separator: separator, bustCache: bustCache)
        return zip(elements, ignored).compactMap { $1 ? nil : $0 }
    }
}

@available(macOS 12, *)
public extension Sequence<FilePath> {
    func checkIgnored(in ignoreFile: String, separator: String = "\n", bustCache: Bool = false) -> [Bool] {
        let joined = map(\.string).joined(separator: separator)
        let result = check_if_ignored_batch(joined, ignoreFile, separator, bustCache)
        return result.toString().split(separator: Character(separator), omittingEmptySubsequences: false).map { $0 == "1" }
    }

    func filterIgnored(in ignoreFile: String, separator: String = "\n", bustCache: Bool = false) -> [Element] {
        let elements = Array(self)
        let ignored = elements.checkIgnored(in: ignoreFile, separator: separator, bustCache: bustCache)
        return zip(elements, ignored).compactMap { $1 ? nil : $0 }
    }
}
