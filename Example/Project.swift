import ProjectDescription
import ProjectDescriptionHelpers

let bundleIdPrefix = "com.weightwatchers."

let baseSettings: SettingsDictionary = [
    "IPHONEOS_DEPLOYMENT_TARGET": "13.0",
    "WATCHOS_DEPLOYMENT_TARGET": "7.1",
    
    "LastUpgradeCheck": "1330"
]

let infoPlist: [String: InfoPlist.Value] = [
    "CFBundleShortVersionString": "1.3.0",
    "CFBundleVersion": "1"
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

let lasso: TargetDependency = .project(target: "Lasso", path: "../")
let lassoTestUtilities: TargetDependency = .project(target: "LassoTestUtilities", path: "../")

let lassoExample = Target(
    name: "Lasso_Example", // we need the underscore to match Pod name
    platform: .iOS,
    product: .app,
    bundleId: bundleIdPrefix + "LassoExample",
    infoPlist: .extendingDefault(with: infoPlist),
    sources: [
        "Lasso/**/*.swift"
    ],
    resources: [
        "Lasso/Base.lproj/**/*",
        "Lasso/Images.xcassets"
    ],
    dependencies: [
        lasso,
        .external(name: "WWLayout")
    ]
)

let lassoTests = Target(
    name: "LassoTests",
    platform: .iOS,
    product: .unitTests,
    bundleId: bundleIdPrefix + "LassoTests",
    infoPlist: .extendingDefault(with: infoPlist),
    sources: [
        "Lasso_Tests/**/*.swift"
    ],
    dependencies: [
        .target(name: "Lasso_Example"),
        lassoTestUtilities
    ]
)

let lassoExampleTests = Target(
    name: "LassoExampleTests",
    platform: .iOS,
    product: .unitTests,
    bundleId: bundleIdPrefix + "LassoExampleTests",
    infoPlist: .extendingDefault(with: infoPlist),
    sources: [
        "Example_Tests/**/*.swift"
    ],
    dependencies: [
        .target(name: "Lasso_Example"),
        lassoTestUtilities
    ]
)

let lassoTestUtilitiesTests = Target(
    name: "LassoTestUtilitiesTests",
    platform: .iOS,
    product: .unitTests,
    bundleId: bundleIdPrefix + "LassoTestUtilitiesTests",
    infoPlist: .extendingDefault(with: infoPlist),
    sources: [
        "LassoTestUtilities_Tests/**/*.swift"
    ],
    dependencies: [
        .target(name: "Lasso_Example"),
        lassoTestUtilities
    ]
)

let project = Project(
    name: "LassoTuistExample",
    organizationName: "WW Tech",
    options: .options(),
    packages: [
    ],
    
    settings: defaultSettings,
    
    targets: [
        lassoExample,
        lassoTests, lassoExampleTests, lassoTestUtilitiesTests
    ],
    
    schemes: [],
    fileHeaderTemplate: nil,
    additionalFiles: [],
    resourceSynthesizers: []
)
