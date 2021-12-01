//___FILEHEADER___

import Foundation
import Lasso

enum ___VARIABLE_name___Screen {
    
    // MARK: State
    
    struct State: Equatable {}
    
    // MARK: Action
    
    enum Action: Equatable {}

    // MARK: Output

    enum Output: Equatable {}
    
}

// MARK: - ScreenModule

extension ___VARIABLE_name___Screen: ScreenModule {
    
    static var defaultInitialState: State { State() }
    
    static func createScreen(with store: ___VARIABLE_name___Store) -> Screen {
        let view = ___VARIABLE_name___ViewController(store: store.asViewStore())
        return Screen(store, view)
    }
    
}
