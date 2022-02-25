//___FILEHEADER___

import Foundation
import Lasso

enum ___VARIABLE_name___Screen: ScreenModule {
    
    static func createScreen(with store: ___VARIABLE_name___Store) -> Screen {
        let view = ___VARIABLE_name___ViewController(store: store.asViewStore())
        return Screen(store, view)
    }
    
    static var defaultInitialState: State { State() }
    
    // MARK: State
    
    struct State: Equatable {
    }
    
    // MARK: Action
    
    enum Action: Equatable {
    }

    // MARK: Output

    enum Output: Equatable {
    }
    
}
