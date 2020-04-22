fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></th>
<th width="33%">Installer Script</th>
<th width="33%">RubyGems</th>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>

# Available Actions
### cart
```
fastlane cart
```
Installs carthage dependencies

runs `carthage bootstrap --platform iOS --cache-builds)`
### provisioning
```
fastlane provisioning
```
Downloads provisioning

Runs `match` to download provisioning profile and certificate or create new one.
#### Options
 * **`configuration`** (Optional): Configuration (e.g. Development). If not provided user is prompted to select from list.
 * **`readonly`** (Default `true`): Runs match in readonly mode. If false, force_for_new_devices is set to true.
### beta
```
fastlane beta
```
Submit new **beta** build to HockeyApp

#### Options
 * **`environment`** (Optional): Defines environment to be built. If not provided `Stage` is used.
### test
```
fastlane test
```
Run automatic tests

#### Options
 * **`type`** (Optional): UI or unit tests. If not provided user is prompted to select from list
### release
```
fastlane release
```
Build and send app to the store

Uses testflight action for submitting
### rename
```
fastlane rename
```
Rename Skeleton

Use this lane when you're creating a new project to rename it from skeleton to desired name.
#### Options
 * **`name`** (Optional): New name of project. If not provided user is prompted to write one.
### add_release_tag
```
fastlane add_release_tag
```
Add git tag

{versionNumber}/{numberOfCommits}
Version number is read from project file and number of commits is calculated from git.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
