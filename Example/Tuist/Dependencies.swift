//
//  Dependencies.swift
//  tuistManifests
//
//  Created by Marius Patru on 09.12.2022.
//

import ProjectDescription

let dependencies = Dependencies(
    carthage: [],
    swiftPackageManager: [
        .remote(url: "https://github.com/ww-tech/wwlayout.git", requirement: .upToNextMajor(from: "0.8.0")),
    ],
    platforms: [.iOS]
)
