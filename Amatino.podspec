Pod::Spec.new do |spec|
    spec.name             = 'Amatino'
    spec.version          = '0.0.7'
    spec.license          = { :type => 'MIT' }
    spec.homepage         = 'https://amatino.io'
    spec.authors          = { 'Hugh Jeremy' => 'hugh@amatino.io' }
    spec.summary          = 'Amatino accounting Swift library for macOS & iOS'
    spec.source           = { :git => 'https://github.com/amatino-code/amatino-swift.git', :tag => spec.version }
    spec.module_name      = 'Amatino'
    spec.swift_version    = '4.0'
    spec.social_media_url = 'https://twitter.com/amatinoapi'
  
    spec.ios.deployment_target  = '10.3'
    spec.osx.deployment_target  = '10.10'
  
    spec.source_files       = 'Sources/Amatino/*'
  end