//___FILEHEADER___

import Lasso
import UIKit

final class ___VARIABLE_name___ViewController: UIViewController, LassoView {
    
    // MARK: Properties
    
    private(set) var store: ___VARIABLE_name___Screen.ViewStore
    
    // MARK: Init
    
    init(store: ___VARIABLE_name___Screen.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { nil }

    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        setUpBindings()
    }
    
    // MARK: SetUp
    
    private func setUpSubviews() {
    }
    
    // MARK: Bindings
    
    private func setUpBindings() {
        // Create state observations using store.observeState()
        // e.g.:
        // store.observeState(\.keyPath.to.value) { [weak self] newValue in
        //     /* do something with newValue */
        // }
        
        // Bind user interactions to Actions using UIKit `.bind()` helpers
        // e.g.:
        // button.bind(to: store, action: .didTapButton)
        // textField.bindTextDidChange(to: store) { ... }
    }
    
}
