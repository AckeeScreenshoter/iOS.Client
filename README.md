# Ackee Screenshotter - ASS

Do you test? We do! 😂 So let's make it a bit less boring 😎 Ass is a **framework** and an **app** designed to save you testing time 💪

## Installation

### Swift Package Manager

**ASS framework** is available through SwiftPM. Add ASS to the `dependencies` value of your `Package.swift`

```
dependencies: [
    .package(url: "git@github.com:AckeeScreenshoter/iOS.Client.git", .upToNextMajor(from: "1.0.0"))
]
```

### Carthage

**ASS framework** is also available through [Carthage](https://github.org/Carthage/Carthage). Just add it to your _Cartfile_. 

```
git "git@github.com:AckeeScreenshoter/iOS.Client.git" ~> 1.0.0
```

**ASS Application** is available through [App Distribution]() .

ASS framework communicates with the ASSApp therefore ASSApp must be installed on the testing device.

## Usage

First the SDK needs to be setup in an application that is to be tested. 

1. Enable ASS.
2. Provide ASS with `base_url` for the Firebase backend.
3. Provide ASS with `auth_token` for the Firebase backend authorization.

This setup is typically done in the app delegate.

```swift
Ass.shared.isEnabled = true
Ass.shared.baseURL = URL(string: "<base_url>")!
Ass.shared.authorization = "<auth_token>"
```

4. Define URL Scheme in `Project Settings -> Target -> Info -> URL Types` by adding a new `URLType` (tapping the plus sign) with **`AckeeScreenshotter`** identifier. The URL Scheme must be different from URL schemes defined in your other URL Types. Also it has to be unique across all the apps installed on a device to function properly. So it is preferred to pick URL Scheme such as `ass-<bundle_id>`. Do not use `ass` as `ass` is a scheme already used by AssApp.

![How to add URL Type](https://user-images.githubusercontent.com/42235915/106173464-3e1bde80-6194-11eb-9597-e710d38ff620.png)

When enabled ASS reacts to taking screenshots and screen capturing.

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

### Show Time

When screen recording, we use ShowTime to show screen touches. This feature is enabled by default but can be disabled when setting up ASS in your application.

```swift
Ass.shared.isVisibleTapsEnabled = false
```

## Framework and App communiaction

Debug application using Ass communicates with the AssApp through URL scheme. 

AssApp reacts to URLs using the `ass` scheme.

All of the debug app information is sent to AssApp through the URL as a query parameter. Ass detects screenshots as well as screen recordings, these are recoginzed by the AssApp through an additional `mediaType` query parameter which can have these values: `screenshot`, `recording`. 

When AssApp is opened with a URL its query parameters are parsed. The query parameters **must** contain `mediaType`, `baseURL`, `authorization` keys where the `mediaType`'s value must be one of the mentioned above. The rest of the parameters are parsed as and additional application information.

## User guide

To use Ass just **take a screenshot** or **stop a video inside** the tested application. 
After one of these actions is detected the user is taken straight to ASS App. In case of a **screenshot** the user can edit the image through the small window that appears in the bottom left corner of the screen. It is also possible to edit the photo in the Gallery and return back to ASSApp. When finished just tap send and your screenshot or records appears on the specified backend.

