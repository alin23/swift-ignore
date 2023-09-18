// swift-tools-version:5.5.0
import PackageDescription
let package = Package(
	name: "Ignore",
	products: [
		.library(
			name: "Ignore",
			targets: ["Ignore"]),
	],
	dependencies: [],
	targets: [
		.binaryTarget(
			name: "IgnoreRustXcframework",
			path: "IgnoreRustXcframework.xcframework"
		),
		.target(
			name: "Ignore",
			dependencies: ["IgnoreRustXcframework"])
	]
)
