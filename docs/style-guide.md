## Lasso style guide

Some general notes about writing idiomatic Lasso code.

Contents:

- [Naming conventions](#naming-conventions)
- [Module definitions](#module-definitions)
- [`switch` case spacing](#switch-case-spacing)



### Naming conventions

When conforming to a Lasso Module (`ScreenModule`, `StoreModule`, `FlowModule`), use the module type in your module name:

```swift
enum MyLoginScreenModule: ScreenModule { ... }
enum CrazyPeopleStoreModule: StoreModule { ... }
enum CoolFeatureFlowModule: FlowModule { ... }
```

When declaring related types (i.e. view controllers, stores), just use the prefix from the module definition, without the extra module type:

```swift
final class MyLoginStore: LassoStore<MyFancyScreenModule> { ... }
final class MyLoginViewController: UIViewController, LassoView { ... }
final class CrazyPeopleStore: LassoStore<CrazyPeopleStoreModule> { ... }
```

`Flow` subclasses should include `Flow` in their name:

```swift
final class CoolFeatureFlow: Flow<CoolFeatureFlowModule> { ... }
```
<br>

### Module definitions

Try to limit module definitions to type declarations.

When defining your `ScreenModule`, `ViewModule`, and `FlowModule` enums, try to limit the code to just declaring new types.  If you need to add functionality (e.g., convenience initializers, etc.), it's better to add these in extensions so that readers can more easily get the big picture of the module.  This allows for easy scanning of the module definition, to quickly get a clear picture of all the module's types.

For example, consider a module definition that mixes type declarations with conveniences and functionality:

```swift
enum MyModule: ScreenModule {
  
  struct State: Equatable {
    let name: String
    var value: Int
    var canSubmit: Bool
    var error: Error?
    
    enum Error: Swift.Error {
      case badInput
      case unknown
      
      var description: String {
        switch self {
          case .badInput: return "invalid input"
          case .unknown: return "unknown error"
        }
      }
    }
    
    init(name: String = "", value: Int = 1) {
      self.name = name
      self.value = value
    }
    
    func updateCanSubmit() {
      canSubmit = !name.isEmpty && value > 1
    }
  }
  
}
```

By moving those conveniences and helpers into extensions outside of the module definition, it becomes easier to read

```swift
enum MyModule: ScreenModule {
  
  struct State: Equatable {
    let name: String
    var value: Int
    var canSubmit: Bool
    var error: Error?
    
    enum Error: Swift.Error {
      case badInput
      case unknown
    }
  }
  
}

extension MyModule.State.Error {
  
  var description: String {
    switch self {
      case .badInput: return "invalid input"
      case .unknown: return "unknown error"
    }
  }
  
}

extension MyModule.State {
  
    init(name: String = "", value: Int = 1) {
      self.name = name
      self.value = value
    }
    
    func updateCanSubmit() {
      canSubmit = !name.isEmpty && value > 1
    }
  
}
```



<br>

### `switch` case spacing

Precede each `switch` `case` statement with an empty line.

Lasso replaces delegate-style protocols with `Action` and `Output` enums.  This allows for precise and flexible conections between types, but also necessitates writing lots of `switch` statements, with potentially non-trivial code per `case`. For readability purposes, it's a best practice in Lasso to have a single empty line preceding each `case` statement - just like it's best to have an empty line preceding each function:

```swift
override func handleAction(_ action: Action) {
  switch action {
  
  case .didSelectItem(let idx):
    guard idx >= 0, idx < state.items.count else { return }
    dispatchOutput(.didSelectItem(state.items[idx]))
  
  case .didAcknowledgeError:
    update { state in
      state.phase = .idle
    }
  }
}
```


