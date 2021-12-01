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
    
}

// MARK: - SetUp

extension ___VARIABLE_name___ViewController {
    
    private func setUpSubviews() {}
    
}

// MARK: - Bindings

extension ___VARIABLE_name___ViewController {
    
    private func setUpBindings() {}
    
}
