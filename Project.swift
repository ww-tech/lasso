import ProjectDescription
import ProjectDescriptionHelpers

let bundleIdPrefix = "com.weightwatchers."

let baseSettings: SettingsDictionary = [
    "IPHONEOS_DEPLOYMENT_TARGET": "13.0",
    "WATCHOS_DEPLOYMENT_TARGET": "7.1",
    
    "LastUpgradeCheck": "1330",
]

let infoPlist: [String: InfoPlist.Value] = [
    "CFBundleShortVersionString": "1.3.0",
    "CFBundleVersion": "1",
]

let defaultSettings: Settings = .settings(
    configurations: [
        .debug(name: "Debug", settings: baseSettings),
        .release(name: "Release", settings: baseSettings),
        .release(name: "AdHoc", settings: baseSettings),
        .release(name: "Enterprise", settings: baseSettings),
        .release(name: "AppStore", settings: baseSettings)
    ]
)

let lasso = Target(
    name: "Lasso",
    platform: .iOS,
    product: .framework,
    bundleId: bundleIdPrefix + "Lasso", infoPlist: .extendingDefault(with: infoPlist),
    sources: [
        "Sources/Lasso/**/*.swift"
    ]
)

let lassoTestUtilities = Target(
    name: "LassoTestUtilities",
    platform: .iOS,
    product: .framework,
    bundleId: bundleIdPrefix + "LassoTestUtilities", infoPlist: .extendingDefault(with: infoPlist),
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
        lasso, lassoTestUtilities,
    ],
    
    schemes: [],
    fileHeaderTemplate: nil,
    additionalFiles: [],
    resourceSynthesizers: []
)
