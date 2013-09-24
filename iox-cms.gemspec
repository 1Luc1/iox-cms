# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iox/version'

Gem::Specification.new do |spec|
  spec.name          = "iox-cms"
  spec.version       = Iox::VERSION
  spec.authors       = ["thorsten zerha"]
  spec.email         = ["thorsten.zerha@tastenwerk.com"]
  spec.description   = %q{ioDa is a content management basement used by TASTENWERK}
  spec.summary       = %q{content management basement}
  spec.homepage      = ""
  spec.license       = "GPLv3"

  spec.files = Dir["{app,config,db,lib}/**/*", "GPLv3-LICENSE", "Rakefile", "README.rdoc"]
  #spec.files         = `git ls-files`.split($/)
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "bcrypt-ruby", "~> 3.0.1"
  spec.add_dependency 'rails_warden'
  spec.add_dependency 'jquery-rails'
  spec.add_dependency 'select2-rails'
  spec.add_dependency 'sass-rails', "~> 4.0.0"
  spec.add_dependency 'paperclip', '~> 3.0'
  spec.add_dependency 'whenever'

end
