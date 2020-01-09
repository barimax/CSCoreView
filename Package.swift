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
        .package(url: "https://github.com/PerfectlySoft/Perfect-CRUD.git", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", "3.0.0"..<"4.0.0"),
        .package(url: "https://github.com/iamjono/SwiftString.git", "2.1.1"..<"3.0.0")
	],
	targets: [
		.target(name: "CSCoreView", dependencies: ["PerfectCRUD", "PerfectMySQL", "SwiftString"]),
		.testTarget(name: "CSCoreViewTests", dependencies: ["CSCoreView"])
	]
)
