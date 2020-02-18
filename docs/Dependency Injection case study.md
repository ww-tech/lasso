## Dependency Injection case study



How to deal with legacy classes

That's a great question.

#### Push.Manager

The `Push.Manager` is set up for mocking, but not in a way that would be very useful to you.  

What you really want to mock is your interface with the manager, rather than the manager's interface with an HTTP service and data model.

Since that manager is a class with no protocol, I think you have two options:
1. make a mock subclass, and override the functions you need in your store
2. make a protocol that represents what you need in the store, and then create a mock that conforms to that protocol.

There's pros and cons to both approaches, but personally I would lean towards a protocol.  Since the manager is a pretty big class that does a lot, if you overrode a small subset of those functions, there's a risk that some other weird side-effects will happen.  In other words, the mock shouldn't really have any functionality in it, except for what is needed to pretend to be a service for your store.

So, what you want to do in my opinion, is to collect all methods you need, and copy/paste those function signatures into a new protocol.

Here's an example with just the `setupReminder` function - this would all go in your reminder store file:
```swift
// set up a base protocol for the reminder store
protocol RemiderServiceProtocol {
    func setupReminder(service: HTTPProtocol, for date: Date, weekday: Weekday, notificationType: String, completion: (() -> Void)?)
}

// set up an extension to handle default parameters
extension RemiderServiceProtocol {
    func setupReminder(for date: Date, weekday: Weekday, notificationType: String, completion: (() -> Void)?) {
        setupReminder(service: Services.notifications, for: date, weekday: weekday, notificationType: notificationType, completion: completion)
    }
}

// make the push manager conform to the protocol:
extension Push.Manager: RemiderServiceProtocol { }

// in the store, just use the protocol
public final class ReminderStore: LassoStore<ReminderScreenModule> {
  var service: RemiderServiceProtocol = Push.shared
  ...
}
```

Then, create your mock:
```swift
final class MockReminderService: RemiderServiceProtocol {

  // capture the completion handler:
  var setupReminderCompletion: (() -> Void)?

  // implement the protocol function, and just grab the completion:
  func setupReminder(service: HTTPProtocol, for date: Date, weekday: Weekday, notificationType: String, completion: (() -> Void)?) {
    setupReminderCompletion = completion
  }
}
```

Inject it when creating your store:
```swift
mockService = MockReminderService()
store.service = mockService
```

Then, in your tests:
```swift
// when you run your unit test, you can then make sure the service function was called:
store.dispatchAction(.submit)
XCTAssertNotNil(mockService.setupReminderCompletion)

// and then call the completion, and test for how the store handles it:
mockService.setupReminderCompletion?()
XCTAssertOutputs([.dismiss])
```

#### PreAuthorizationAlert

Similar to the Push manager, you just want to test your interface with the pre-auth alert, and ignore what happens with UIKit.

Existing:

```swift
public enum PreAuthorizationAlert {
  
  public static func presentPreAuthorizationAlert() { ... }
  
}
```



This is a little easier to deal with.  Since it's a case-less enum, I would change it to be a protocol / struct - something like this (only the public funcs would go into the protocol):

```swift
protocol PreAuthorizationAlertProtocol {
  public func presentPreAuthorizationAlert()
}

struct PreAuthorizationAlert: PreAuthorizationAlertProtocol {

  public static let shared: PreAuthorizationAlertProtocol = PreAuthorizationAlert()

  public func presentPreAuthorizationAlert() {
    ...
  }
}
```

You can do the same mocking as described above for the Push manager.
```swift
public final class ReminderStore: LassoStore<ReminderScreenModule> {
  var preAuthAlert: PreAuthorizationAlertProtocol = PreAuthorizationAlert.shared
  ...
}
```
etc.

I think this is the longest review comment I've ever written.