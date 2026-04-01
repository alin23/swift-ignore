import IgnoreRust

public func check_if_ignored<GenericToRustStr: ToRustStr>(_ path: GenericToRustStr, _ ignore_file: GenericToRustStr, _ bust_cache: Bool) -> Bool {
    ignore_file.toRustStr { ignore_fileAsRustStr in
        path.toRustStr { pathAsRustStr in
            __swift_bridge__$check_if_ignored(pathAsRustStr, ignore_fileAsRustStr, bust_cache)
        }
    }
}
public func check_if_ignored_batch<GenericToRustStr: ToRustStr>(_ paths: GenericToRustStr, _ ignore_file: GenericToRustStr, _ separator: GenericToRustStr, _ bust_cache: Bool) -> RustString {
    separator.toRustStr { separatorAsRustStr in
        ignore_file.toRustStr { ignore_fileAsRustStr in
            paths.toRustStr { pathsAsRustStr in
                RustString(ptr: __swift_bridge__$check_if_ignored_batch(pathsAsRustStr, ignore_fileAsRustStr, separatorAsRustStr, bust_cache))
            }
        }
    }
}
public func bust_gitignore_cache() {
    __swift_bridge__$bust_gitignore_cache()
}
