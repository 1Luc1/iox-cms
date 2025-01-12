# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iox/version'

Gem::Specification.new do |spec|
  spec.name          = "iox-cms"
  spec.version       = Iox::VERSION
  spec.authors       = ["thorsten zerha"]
  spec.email         = ["thorsten.zerha@tastenwerk.com"]
  spec.description   = %q{ioxCMS is a content management basement used by TASTENWERK}
  spec.summary       = %q{content management basement}
  spec.homepage      = "https://github.com/tastenwerk/iox-cms"
  spec.license       = "GPLv3"

  spec.files = Dir["{app,config,db,lib}/**/*", "GPLv3-LICENSE", "Rakefile", "README.rdoc"]
  #spec.files         = `git ls-files`.split($/)
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.4.2"

  spec.add_dependency "bcrypt-ruby", "~> 3.1.2"
  spec.add_dependency 'rails_warden', "~> 0.6.0"
  spec.add_dependency 'jquery-rails', "~> 4.6.0"
  spec.add_dependency 'select2-rails', '3.5.0'
  spec.add_dependency 'sass-rails', "~> 5.0.7"
  spec.add_dependency 'paperclip', '~> 4.0'
  spec.add_dependency 'whenever', "~> 1.0.0"

  spec.add_dependency 'nokogiri', '~> 1.10.10'
  spec.add_dependency 'premailer-rails', '~> 1.9.7'

  spec.add_dependency 'rqrcode-rails3', "~> 0.1.7" # used in user qr code confirmation code generation
  spec.add_dependency 'mini_magick', "~> 5.0.1"
  spec.add_dependency 'vpim', "~> 24.2.20"

end
