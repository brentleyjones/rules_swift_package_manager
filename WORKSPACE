workspace(name = "cgrindel_swift_bazel")

load("//:deps.bzl", "swift_bazel_dependencies")

swift_bazel_dependencies()

# MARK: - Starlark

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

# MARK: - Golang

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

# gazelle:repo bazel_gazelle

load("//:go_deps.bzl", "swift_bazel_go_dependencies")

# Workaround for missing strict deps error as described here:
# https://github.com/bazelbuild/bazel-gazelle/issues/1217#issuecomment-1152236735
# gazelle:repository go_repository name=in_gopkg_alecthomas_kingpin_v2 importpath=gopkg.in/alecthomas/kingpin.v2

# gazelle:repository_macro go_deps.bzl%swift_bazel_go_dependencies
swift_bazel_go_dependencies()

# MARK: - Skylib Gazelle Extension

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib_gazelle_plugin",
    sha256 = "04182233284fcb6545d36b94248fe28186b4d9d574c4131d6a511d5aeb278c46",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.0/bazel-skylib-gazelle-plugin-1.4.0.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.0/bazel-skylib-gazelle-plugin-1.4.0.tar.gz",
    ],
)

load("@bazel_skylib_gazelle_plugin//:workspace.bzl", "bazel_skylib_gazelle_plugin_workspace")

bazel_skylib_gazelle_plugin_workspace()

go_rules_dependencies()

go_register_toolchains(version = "1.19.5")

gazelle_dependencies()

# MARK: - Bazel Integration Test

http_archive(
    name = "contrib_rules_bazel_integration_test",
    sha256 = "d828f2ed25775cefefeba2025db4d82590bd4b6ca05037d230d8492c1fd1edf2",
    strip_prefix = "rules_bazel_integration_test-0.10.0",
    urls = [
        "http://github.com/bazel-contrib/rules_bazel_integration_test/archive/v0.10.0.tar.gz",
    ],
)

load("@contrib_rules_bazel_integration_test//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("@contrib_rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")
load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)

# Go Deps for bazel-starlib

load("@cgrindel_bazel_starlib//:go_deps.bzl", "bazel_starlib_go_dependencies")

bazel_starlib_go_dependencies()
