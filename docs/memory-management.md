## Memory management


### Strong reference cycles

When you create your view controller you'll hold a strong reference to the store like this:

```swift
final class MyViewController: UIViewController, LassoView {

  let store: MyScreenModule.ViewStore
  
  init(_ store: ViewStore) {
    self.store = store
    super.init()
  }
```

This is good - as long as the view controller is present in the view hierarchy the store will be kept alive.  In  order to avoid strong reference cycles, take care when referencing your controller and store.  When implementing state observations in your view controller, make sure to capture `self` weakly.

```swift
  private func setUpBindings() {
    store.observeState(\.name) { [weak self] name in
      self?.nameField.text = name
    }
  }
```

Or, when observing outputs:
```swift
  MyScreenModule
    .createScreen()
    .observeOutput { [weak self] output in
      switch output {
        ...
      }
    }
```

### Who owns the `Flow`?

[TL;DR] The initial view controller.

When you start a `Flow` by calling `start(with:)`, a strong reference will automatically be created for you from the initial UIViewController to the `Flow` instance.  This avoids the need for "dispose bag" kinds of constructs.

Under normal circumstances when the initial view controller of a `Flow` is removed from the view hierarchy, the `Flow` instance that created it will also get released.

The same caveat above about referencing self applies here too - a `Flow` should _always_ captures self weakly in output observations to avoid strong reference cycles.

```swift
private func showFancyFlow() {
  FancyFlow()
    .observeOutput { [weak self] output in
      switch output {
        ...
      }
    }
    .start(with: rootOfApplicationWindow())
}
```

If a Flow needs to hold a reference to a controller, that reference should also be `weak`.

```swift
class FancyFlow: Flow {
  weak var someController: SomeViewController?
  private func showSomeScreen() {
    someController = SomeScreenModule
    	.createScreen()
    	.observeOutput { [weak self] output in
    	  ...
    	}
    	.controller
  }
}
```



### Look for reference cycles!

Every so often it's a good idea to open up the Debug Memory Graph in Xcode, and see if there are any unexpected objects still in memoery.
