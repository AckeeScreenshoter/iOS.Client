source "https://rubygems.org"

gem 'fastlane', '~> 2.130'
gem "xcode-install", '~> 2.6'
gem "cocoapods", '~> 1.7'

def is_ackee() %x( git config user.email ).strip.downcase.include? "@ackee.cz" end

gem "ACKFastlane", :git => "git@gitlab.ack.ee:iOS/fastlane.git", :tag => "2.2.1" if is_ackee

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
