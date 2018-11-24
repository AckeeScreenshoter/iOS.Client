# ASS

Do you test? We do! 😂 So let's make it a bit less boring 😎 Ass is designed to save your testing time 💪

## Installation

Ass is available through [Carthage](https://github.org/Carthage/Carthage). Just add it to your _Cartfile_.

## Usage

First you need to setup the SDK. You need to provide `baseURL` for the Firebase backend and `authorization` token. Typically you will do that in the app delegate.

```swift
Ass.baseURL = URL("https://ass-ee.firebaseapp.com/upload")!
Ass.authorization = "<auth_token>"
```

Then conform ther `UIResponder`s you would like to be debuggable to the `Debuggable` protocol. You'd probably want all you view controllers to be `Debuggable` - we suggest to have a common parent class for all app controllers. After that you can choose how you would like to trigger the debug/screenshot screen. When the gesture is recognized just call `presentDebugController()` method - Here we suggest using a shake gesture so the example view controller would look like this.

```swift
final class BaseViewController: UIViewController, Debuggable {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard case .motionShake = motion else { return }
        presentDebugController()
    }
}
```

Everything later on is handle by ass automatically so you have no more work to do.

## What is sent to backend?

Along with the screenshot we send additional metadata
- device make (_Apple_)
- device model (_iPhone X_)
- iOS version (_12.1_)
- app version (_1.0_)
- build number (_563_)
- platform (_ios_)
- app name

### Custom data

You can also add you custom data like user account by setting properties on `Ass`
```
Ass.customData = ["account": "pan.unicorn@ackee.cz"]
```