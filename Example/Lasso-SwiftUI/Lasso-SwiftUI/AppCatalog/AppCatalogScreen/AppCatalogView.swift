//
// ==----------------------------------------------------------------------== //
//
//  AppCatalogView.swift
//
//  Created by Steven Grosmark on 03/23/2021.
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2021 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import SwiftUI
import Lasso

struct AppCatalogView: View {
    
    @ObservedObject private(set) var store: AppCatalogScreen.ViewStore
    
    var body: some View {
        VStack {
            Text(store.state.title).padding()
            List {
                ForEach(store.state.sections) { section in
                    Section(header: CatalogSectionHeader(section: section)) {
                        ForEach(section.items) { item in
                            NavigationRow(item.title, target: store, action: item)
                        }
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .navigationBarTitle("Samples")
    }
}

private struct CatalogSectionHeader: View {
    let section: AppCatalogScreen.Section
    var body: some View {
        HStack {
            Image(systemName: section.systemImage)
            Text(section.title)
        }
    }
}

extension AppCatalogScreen.Section {
    
    fileprivate var systemImage: String {
        switch self {
        case .screens: return "doc"
        case .flows: return "doc.on.doc"
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        let store = AppCatalogStore(with: AppCatalogScreen.defaultInitialState)
        AppCatalogView(store: store.asViewStore())
    }
}
