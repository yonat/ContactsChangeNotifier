// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ContactsChangeNotifier",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "ContactsChangeNotifier", targets: ["ContactsChangeNotifier", "ContactStoreChangeHistory"]),
    ],
    targets: [
        .target(
            name: "ContactStoreChangeHistory"
        ),
        .target(
            name: "ContactsChangeNotifier",
            dependencies: ["ContactStoreChangeHistory"],
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
    ],
    swiftLanguageModes: [.v5, .v6]
)
