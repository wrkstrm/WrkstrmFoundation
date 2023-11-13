load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(default_visibility = ["//visibility:public"])

objc_library(
    name = "WSFoundation-objc",
    module_name = "WrkstrmFoundationObjc",
    hdrs = glob(["Source/ObjC/*.h"]),
    srcs = glob(["Source/ObjC/*.m"]),
    alwayslink = True,
)

swift_library(
    name = "WSFoundation-swift",
    module_name = "WrkstrmFoundation",
    srcs = glob(["Source/Swift/**/*.swift"]),
)
