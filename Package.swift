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
			name: "RustXcframework",
			path: "RustXcframework.xcframework"
		),
		.target(
			name: "Ignore",
			dependencies: ["RustXcframework"])
	]
)
	