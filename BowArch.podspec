Pod::Spec.new do |s|
  s.name        = "BowArch"
  s.version     = "0.1.0"
  s.summary     = "BowArch is a library to architect SwiftUI-based apps in a functional way."
  s.homepage    = "https://github.com/bow-swift/bow-arch"
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.authors     = "The Bow authors"

  s.requires_arc = true
  s.osx.deployment_target = "10.15"
  s.ios.deployment_target = "13.0"
  #s.tvos.deployment_target = "9.1"
  #s.watchos.deployment_target = "2.0"
  s.source   = { :git => "https://github.com/bow-swift/bow-arch.git", :tag => "#{s.version}" }
  s.source_files = "Sources/BowArch/**/*.swift"
  s.dependency "Bow", "~> 0.8.0"
  s.dependency "BowEffects", "~> 0.8.0"
  s.dependency "BowOptics", "~> 0.8.0"
  s.swift_versions = ["5.2"]
end
