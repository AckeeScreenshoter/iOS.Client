source "https://rubygems.org"

gem 'fastlane', '~> 2.144'
gem "xcode-install", '~> 2.6'
gem "cocoapods", '~> 1.7'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
