import ProjectDescription
import ProjectDescriptionHelpers

let bundleIdPrefix = ""

let baseSettings: SettingsDictionary = [
    "IPHONEOS_DEPLOYMENT_TARGET": "13.0",
    "WATCHOS_DEPLOYMENT_TARGET": "7.1",
    
    "LastUpgradeCheck": "1330",
]

let defaultSettings: Settings = .settings(
    configurations: [
        .debug(name: "Debug", settings: baseSettings, xcconfig: nil),
        .release(name: "Release", settings: baseSettings, xcconfig: nil),
    ]
)

let lasso = Target(
    name: "Lasso",
    platform: .iOS,
    product: .framework,
    bundleId: bundleIdPrefix + "Lasso", infoPlist: .default,
    sources: [
        "Sources/Lasso/**/*.swift"
    ]
)

let lassoTestUtilities = Target(
    name: "LassoTestUtilities",
    platform: .iOS,
    product: .framework,
    bundleId: bundleIdPrefix + "LassoTestUtilities", infoPlist: .default,
    sources: [
        "Sources/LassoTestUtilities/**/*.swift"
    ],
    dependencies: [.target(name: "Lasso"), .xctest]
)

let project = Project(
    name: "LassoTuist",
    organizationName: "WW Tech",
    options: .options(),
    packages: [
    ],
    
    settings: defaultSettings,
    
    targets: [
        lasso, lassoTestUtilities
    ],
    
    schemes: [],
    fileHeaderTemplate: nil,
    additionalFiles: [],
    resourceSynthesizers: []
)
