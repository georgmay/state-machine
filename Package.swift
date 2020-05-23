// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "StateMachine",
	platforms: [
		.macOS(.v10_13), 
		.iOS(.v11), 
		.tvOS(.v11)
	],
	products: [
		.library(name: "StateMachine", targets: ["StateMachine"]),
	],
	dependencies: [
		.package(url: "https://github.com/Quick/Quick.git", from: "2.2.0"),
		.package(url: "https://github.com/Quick/Nimble.git", from: "8.0.9"),
	],
	targets: [
		.target(name: "StateMachine", dependencies: [], path: "Sources"),
		.testTarget(name: "StateMachineTests", dependencies: ["StateMachine", "Quick", "Nimble"]),
	],
	swiftLanguageVersions: [.v5]
)
