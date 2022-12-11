"""Tests for `swiftpkg_bld_decls` module."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//swiftpkg/internal:build_decls.bzl", "build_decls")
load("//swiftpkg/internal:build_files.bzl", "build_files")
load("//swiftpkg/internal:load_statements.bzl", "load_statements")
load("//swiftpkg/internal:pkginfo_targets.bzl", "pkginfo_targets")
load("//swiftpkg/internal:pkginfos.bzl", "library_type_kinds", "pkginfos")
load(
    "//swiftpkg/internal:swiftpkg_build_files.bzl",
    "native_kinds",
    "swift_kinds",
    "swift_library_load_stmt",
    "swift_location",
    "swift_test_load_stmt",
    "swiftpkg_build_files",
)

_repo_name = "@realm_swiftlint"

# This is a simplified version of SwiftLint.
_pkg_info = pkginfos.new(
    name = "SwiftLint",
    path = "/path/to/swiftlint",
    dependencies = [
        pkginfos.new_dependency(
            identity = "swift-argument-parser",
            type = "sourceControl",
            url = "https://github.com/apple/swift-argument-parser.git",
            requirement = pkginfos.new_dependency_requirement(
                ranges = [
                    pkginfos.new_version_range("0.3.1", "0.4.0"),
                ],
            ),
        ),
    ],
    products = [
        pkginfos.new_product(
            name = "swiftlint",
            type = pkginfos.new_product_type(executable = True),
            targets = ["swiftlint"],
        ),
        pkginfos.new_product(
            name = "SwiftLintFramework",
            type = pkginfos.new_product_type(
                library = pkginfos.new_library_type(
                    library_type_kinds.automatic,
                ),
            ),
            targets = ["SwiftLintFramework"],
        ),
    ],
    targets = [
        # Old-style regular library that is used to create a binary from an
        # executable product.
        pkginfos.new_target(
            name = "swiftlint",
            type = "regular",
            c99name = "swiftlint",
            module_type = "SwiftTarget",
            path = "Source/swiftlint",
            sources = [
                "Commands/SwiftLint.swift",
                "main.swift",
            ],
            dependencies = [
                pkginfos.new_target_dependency(
                    by_name = pkginfos.new_target_reference(
                        "SwiftLintFramework",
                    ),
                ),
            ],
        ),
        pkginfos.new_target(
            name = "SwiftLintFramework",
            type = "regular",
            c99name = "SwiftLintFramework",
            module_type = "SwiftTarget",
            path = "Source/SwiftLintFramework",
            sources = [
                "SwiftLintFramework.swift",
            ],
            dependencies = [],
        ),
        pkginfos.new_target(
            name = "SwiftLintFrameworkTests",
            type = "test",
            c99name = "SwiftLintFrameworkTests",
            module_type = "SwiftTarget",
            path = "Tests/SwiftLintFrameworkTests",
            sources = [
                "SwiftLintFrameworkTests.swift",
            ],
            dependencies = [
                pkginfos.new_target_dependency(
                    by_name = pkginfos.new_target_reference(
                        "SwiftLintFramework",
                    ),
                ),
            ],
        ),
    ],
)

def _swift_library_target_test(ctx):
    env = unittest.begin(ctx)

    target = pkginfo_targets.get(_pkg_info.targets, "SwiftLintFramework")
    actual = swiftpkg_build_files.new_for_target(_pkg_info, target, _repo_name)
    expected = build_files.new(
        load_stmts = [swift_library_load_stmt],
        decls = [
            build_decls.new(
                kind = swift_kinds.library,
                name = "SwiftLintFramework",
                attrs = {
                    "deps": [],
                    "module_name": "SwiftLintFramework",
                    "srcs": [
                        "SwiftLintFramework.swift",
                    ],
                    "visibility": ["//visibility:public"],
                },
            ),
        ],
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

swift_library_target_test = unittest.make(_swift_library_target_test)

def _swift_library_target_for_binary_test(ctx):
    env = unittest.begin(ctx)

    # The swiftlint target is an older style executable definition (regular).
    # We create the swift_library in the target package. Then, we create the
    # executable when defining the product.
    target = pkginfo_targets.get(_pkg_info.targets, "swiftlint")
    actual = swiftpkg_build_files.new_for_target(_pkg_info, target, _repo_name)
    expected = build_files.new(
        load_stmts = [swift_library_load_stmt],
        decls = [
            build_decls.new(
                kind = swift_kinds.library,
                name = "swiftlint",
                attrs = {
                    "deps": [
                        "@realm_swiftlint//Source/SwiftLintFramework",
                    ],
                    "module_name": "swiftlint",
                    "srcs": [
                        "Commands/SwiftLint.swift",
                        "main.swift",
                    ],
                    "visibility": ["//visibility:public"],
                },
            ),
        ],
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

swift_library_target_for_binary_test = unittest.make(_swift_library_target_for_binary_test)

def _swift_test_target_test(ctx):
    env = unittest.begin(ctx)

    target = pkginfo_targets.get(_pkg_info.targets, "SwiftLintFrameworkTests")
    actual = swiftpkg_build_files.new_for_target(_pkg_info, target, _repo_name)
    expected = build_files.new(
        load_stmts = [swift_test_load_stmt],
        decls = [
            build_decls.new(
                kind = swift_kinds.test,
                name = "SwiftLintFrameworkTests",
                attrs = {
                    "deps": [
                        "@realm_swiftlint//Source/SwiftLintFramework",
                    ],
                    "module_name": "SwiftLintFrameworkTests",
                    "srcs": [
                        "SwiftLintFrameworkTests.swift",
                    ],
                    "visibility": ["//visibility:public"],
                },
            ),
        ],
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

swift_test_target_test = unittest.make(_swift_test_target_test)

def _products_test(ctx):
    env = unittest.begin(ctx)

    actual = swiftpkg_build_files.new_for_products(_pkg_info, _repo_name)
    expected = build_files.new(
        load_stmts = [
            load_statements.new(swift_location, swift_kinds.binary),
        ],
        decls = [
            build_decls.new(
                kind = native_kinds.alias,
                name = "SwiftLintFramework",
                attrs = {
                    "actual": "@realm_swiftlint//Source/SwiftLintFramework",
                    "visibility": ["//visibility:public"],
                },
            ),
            build_decls.new(
                kind = swift_kinds.binary,
                name = "swiftlint",
                attrs = {
                    "deps": ["@realm_swiftlint//Source/swiftlint"],
                    "visibility": ["//visibility:public"],
                },
            ),
        ],
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

products_test = unittest.make(_products_test)

def swiftpkg_build_files_for_old_style_pkg_test_suite():
    return unittest.suite(
        "swiftpkg_build_files_for_old_style_pkg_tests",
        swift_library_target_test,
        swift_library_target_for_binary_test,
        swift_test_target_test,
        products_test,
    )