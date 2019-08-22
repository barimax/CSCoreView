// swift-tools-version:4.2
// Generated automatically by Perfect Assistant
// Date: 2019-08-22 13:21:10 +0000
import PackageDescription

let package = Package(
	name: "CSCoreView",
	products: [
		.library(name: "CSCoreView", targets: ["CSCoreView"])
	],
	dependencies: [
        .package(url: "https://github.com/barimax/CSCoreDB.git", .branch("master")),
	],
	targets: [
		.target(name: "CSCoreView", dependencies: ["CSCoreDB"]),
		.testTarget(name: "CSCoreViewTests", dependencies: ["CSCoreView"])
	]
)
