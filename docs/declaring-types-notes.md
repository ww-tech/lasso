

## Notes about declaring types

### `ScreenModule`

#### `State`

When declaring `State`, and deciding where and how to declare the individual pieces of content for a `Screen`, there are generally three kinds of content:

- **Dynamic** - these are parts of the screen that can change _while it is running_ -  `username` and `password` fields for a login screen are great examples of this, as they change when the user types.
  Dynamic `State` properties are declared as a `var`.
- **Screen invariant** - pieces of content that will _never_ change during the lifetime of a screen instance, but could differ from instance to instance.  For example, we could add a `message` property to the login screen for describing why a user needs to login - e.g., "Log in to change your settings", or "Confirm your login to delete your account".
  Invariant `State` properties are declared as a `let`.
- **Constant** - These are things that are always the same, no matter what.  For example, the login screen in our fictitious app will _always_ have the title "Login".
  Constants aren't added to `State`.


```swift
enum State: Equatable {
  var username: String
  var password: String
  let message: String
}
```

#### `Action`

An interesting way to think about `Action` cases is as functions in a protocol.  E.g., consider the set of `Actions`:

```swift
enum Action: Equatable {
  case didTapButton
  case didEnterValue(String)
}
```

is analgous to this protocol:

```swift
protocol MyScreenActionDelegate {
  func didTapButton()
  func didEnterValue(_ value: String)
}
```

The nice thing about `Actions` as enum cases is that:

- you can collect them - e.g. as an undo stack, or for unit testing purposes;
- they can be comparable for easy unit testing - e.g., to make sure a a `View` produces the proper actions in response to user actions.
- they are a concrete type - so they can be nested within another type (as we do in a `ScreenModule`), and they play well with generics.


####  `createScreen`

There are a few convenience versions of `createScreen` available.  The most commonly used - besides the no-argument version - is the one that allows for a specific initial state.  In a login screen example, if we wanted to pre-populate our username field with the last username used, we can call a version of `createScreen` that allows us to specify an initial state:

```swift
let initialState = LoginScreenModule.State(username: "Billie")
let screen = LoginScreenModule.createScreen(with: initialState)
```

Note that it's quite common to create your own versions of `createScreen`, to allow for even more concise usage:

```swift
public static func createScreen(username: String) -> Screen {
  let initialState = LoginScreenModule.State(username: username)
  return createScreen(with: initialState)
}

// Client usage:
let screen = LoginScreenModule.createScreen(username: "Billie")
```



#### Default types

##### `ScreenModule` / `StoreModule`

You don't _have_ to declare all of the value types in a `ScreenModule`.  For, example if you don't need an `Output`, there's no need to declare an empty enum for it.  When left out, a `ScreenModule`'s' `Output` will be declared for you as `NoOutput`, which is in fact just an empty enum.  `Action` defaults to `NoAction`, and `State` to `EmptyState`.  The only component with no default value is the `createScreen` function - this function must always be defined.

```swift
enum BlankModule: ScreenModule {
    static func createScreen(with store: BlankStore) -> Screen {
        return Screen(store, UIViewController())
    }
}

final class BlankStore: LassoStore<BlankModule> {
}
```

Technically speaking, `Action`, `Output`, and `State` are all associated types in the `StoreModule` protocol.  `ScreenModule` _is_ a protocol with `StoreModule` conformance plus the notion of a `Store` and `UIViewController` grouped as a `Screen`

##### `FlowModule`

The `FlowModule` protocol also has defaults for the types you can declare.  Similar to `ScreenModule`, `Output` is defaulted to `NoOutput` in a `FlowModule`. The `RequiredContext` associated type is defaulted to `UIViewController`.  If your module has no special placement requirements, you can leave out the `RequiredContext`:

```swift
enum MyFlowModule: FlowModule {
  enum Output: Equatable {
    case somethingHappened
  }
}
```

Furthermore, in cases where you're writing a module that will not emit any output, you can leave out that declaration, too.

There are also some pre-defined modules for common situations, so you can even get away with _not_ explicitly declaring your own `FlowModule`.  These are:

- `NoOutputFlow`
  - `Output` = `NoOutput`
  - `RequiredContext` = `UIViewController`
- `NoOutputNavigationFlow`
  - `Output` = `NoOutput`
  - `RequiredContext` = `UINavigationController`

