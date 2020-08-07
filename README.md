# Ass - Ackee screenshotter

Do you test? We do! 😂 So let's make it a bit less boring 😎 Ass is designed to save your testing time 💪

## Installation

**Ass framework** is available through [Carthage](https://github.org/Carthage/Carthage). Just add it to your _Cartfile_. 

```
git "git@gitlab.ack.ee:iOS/Ass.git" ~> 0.2.0
```

**Ass application** is available through [App Distribution]() .

Ass framework communicates with the AssApp so the AssApp must be installed on the testing device.

## Usage

First you need to setup the SDK. 

1. Enable ASS.
2. Provide ASS with `baseURL` for the Firebase backend.
3. Provide ASS with **[<auth_token>](https://ackee.passwd.team/secrets/utLLPiEx8RhCyab8m8bP)** for Firebase backend authorization.

This setup is typically done in the app delegate.

```swift
Ass.shared.isEnabled = true
Ass.shared.baseURL = URL(string: "https://ass-ee.firebaseapp.com/upload")!
Ass.shared.authorization = <auth_token>
```

4. Define URL Scheme in `Project Settings -> Target -> Info -> URL Types` by adding a new `URLType` (tapping the plus sign) with **`AckeeScreenshotter`** identifier. The URL Scheme must be different from URL schemes defined in your other URL Types. Also it has to be unique across all the apps installed on a device to function properly. So it is preferred to pick URL Scheme such as `ass-my-app` over `ass` as `ass` is a scheme already used by AssApp.

When enabled Ass reacts to taking screenshots and screen capturing.

## What is sent to backend?

Along with the screenshot we send additional metadata
- device make (_Apple_)
- device model (_iPhone X_)
- iOS version (_12.1_)
- app version (_1.0_)
- build number (_563_)
- platform (_ios_)
- app name

These have their defaults but can also be changed if needed.

```swift
Ass.shared.appInfo.appName = "XY"
```

### Custom data

Custom data like user account can also be added by setting properties on `Ass.shared`

```swift
Ass.shared.appInfo.customData = ["account": "pan.unicorn@ackee.cz"]
```

### Note

AssApp allows the user to take a note that is also sent to the backend.

## Framework and App communiaction

Debug application using Ass communicates with the AssApp through URL scheme. 

AssApp reacts to URLs using the `ass` scheme.

All of the debug app information is sent to AssApp through the URL as a query parameter. Ass detects screenshots as well as screen recordings, these are recoginzed by the AssApp through an additional `mediaType` query parameter which can have these values: `screenshot`, `recording`. 

When AssApp is opened with a URL its query parameters are parsed. The query parameters **must** contain `mediaType`, `baseURL`, `authorization` keys where the `mediaType`'s value must be one of the mentioned above. The rest of the parameters are parsed as and additional application information.

## User guide

To use Ass just **take a screenshot** or **stop a video inside** your debug application. 
After one of these actions is detected the user is taken straight to AssApp. In case of a **screenshot** the user can edit the image through the small window that appears in the bottom left corner of the screen. It is also possible to edit the photo in the Gallery and return back to AssApp. When finished just tap send and your screenshot or records appears in [Ass on the web](https://ass-ee.firebaseapp.com/)

