// swift-tools-version:6.0
import PackageDescription

let package = Package(
	name: "StateMachine",
	platforms: [
		.macOS(.v12),
		.iOS(.v15),
		.tvOS(.v15)
	],
	products: [
		.library(name: "StateMachine", targets: ["StateMachine"]),
	],
	dependencies: [],
	targets: [
		.target(name: "StateMachine", dependencies: [], path: "Sources"),
		.testTarget(name: "StateMachineTests", dependencies: ["StateMachine"]),
	],
	swiftLanguageModes: [.v6]
)
