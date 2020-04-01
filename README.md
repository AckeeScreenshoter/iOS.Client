# ProjectTemplate

Good old `project-skeleton` is dead! :scream: Also name *Skeleton* is dead, now it's **Project Template**

It's splitted to two parts - public and private.

## Public part
Whole template is opensourced and available on https://github.com/AckeeCZ/iOS-MVVM-ProjectTemplate

**Start new project from there!** Follow usage guide and documentation. When you're finished - means your project is renamed from ProjectTemplate to your new project name, go back here and import private part.

Go back here **WHEN IT'S RENAMED** :warning: Next step will remove `rename` lane from Fastfile, so it's really a good idea to rename it first.

## Private part

1. Some files must not be seen by public so download them from this repo. Just paste following command to terminal and hit Enter.
```bash
git archive --remote=git@gitlab.ack.ee:iOS/project-template.git master --format=zip -o private.zip && unzip -o private.zip -x README.md && rm private.zip
```

2. Update `Gemfile` acording to installation guide in <https://gitlab.ack.ee/iOS/fastlane>
3. Update `Jenkinsfile` with correct Slack channel for CI and correct HockeyApp app identifier
4. if you already have production developer account and iTC account, you can fill also those credentials into `Fastfile`  

**Now project should be ready to start :rocket:**

***

## Dependency management

Now preferred way of dependency management is [Carthage](https://github.com/Carthage/Carthage) with [Rome](https://github.com/blender/Rome). Only dependencies which do not support it can be integrated using [Cocoapods](https://cocoapods.org).

### Rome

#### First time working on the project

When you are working on the project for the first time you should start by executing
```
pod install
```
to install our Fastfile. Then you should execute
```
bundle exec fastlane cart
```
to download all dependencies and build the missing ones. If some of the dependencies are missing in the cache, you have to check the Romefile for correct mapping and upload them to the cache, so our CI is not building them again.

#### Add / update dependency

To add or update dependency you should use
```
bundle exec fastlane rome_update dependencies:ACKategories
```
If you need to add or update more than one depedency, the command is the same but each dependency is seperated by space and passed as a string to the command
```
bundle exec fastlane rome_update dependencies:"ACKategories Marshal"
```

### Carthage

At first I recommend [the official Carthage README](https://github.com/Carthage/Carthage/blob/master/README.md). This is just a basic tutorial for most common commands.

Generally Carthage uses two main files - **Cartfile** which holds list of dependencies (equal to *Podfile* in *Cocoapods*) and **Cartfile.resolved** which holds real versions that were installed (equal to *Podfile.lock* in *Cocoapods*)

#### Installing resolved versions

To install previously resolved versions of dependencies (all in Cartfile.resolved) run:

```bash
carthage bootstrap --platform iOS --cache-builds
```

This will install all dependencies in Cartfile.resolved and build them for the iOS platform.

***NOTE: If you have added any dependency to Cartfile, it will not be installed as it is not yet in the Cartfile.resolved file, so it isn't equivalent to `pod install` command***

#### Installing new dependency

If you're adding a new dependency - you want Carthage to add it to the Cartfile.resolved file, you should run:

```bash
carthage update --platform iOS --cache-builds <dependency_name>
```

If the dependency already existed it will be updated according to specified version in Cartfile. If the `dependency_name` argument is omitted, Carthage will install the newest versions of all dependencies according to Cartfile so be careful.

`carthage update` should be equivalent to calling `pod update` in Cocoapods.

#### Updating dependencies

This will update all dependecies from Cartfile (like if Cartfile.resolved never existed)

```bash
carthage update --platform iOS --cache-builds
```

#### Useful stuff for Carthage

I use some aliases for bash which simplify Carthage calls

```bash
alias cb='carthage bootstrap --platform iOS --cache-builds'
alias cu='carthage update --platform iOS --cache-builds'
```

For complete dependency management there is a lane `cart` which runs `carthage bootstrap` with some default parameters so you don't have to care really.
```bash
bundle exec fastlane cart
```

### Cocopoads

If your dependency doesn't support Carthage or it doesn't make sense (SwiftGen, ACKLocalization, ...) just integrate it using Cocoapods.


## App release

The `appstore` lane was renamed to `release` lane so it doesn't interfere with built-in fastlane action.

According to #procesy the username used to access developer portal and iTC should be the same as your git username. If you need to customize this behavior you can override the `itc_apple_id()` or `dev_portal_apple_id()` function.

Release lane just uploads build to iTC (it uses `testflight` action instead of `deliver`) so it just requires *Developer* permission on iTC.
