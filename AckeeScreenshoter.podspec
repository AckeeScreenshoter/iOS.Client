Pod::Spec.new do |spec|
    spec.name         = 'AckeeScreenshoter'
    spec.version      = '1.2.6'
    spec.license      = { :type => 'MIT', :file => 'LICENSE' }
    spec.homepage     = 'https://github.com/AckeeScreenshoter/iOS.Client'
    spec.authors      = { 'Ackee' => 'info@ackee.cz' }
    spec.summary      = 'Ackee Screenshoter'
    spec.source       = { :git => 'https://github.com/AckeeScreenshoter/iOS.Client.git', :tag => spec.version }
    spec.ios.deployment_target  = '10.0'
    spec.swift_version = '5.0'
    spec.ios.source_files = ['AssCore/**/*.swift', 'Ass/**/*.swift']
end  
