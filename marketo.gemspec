# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "marketo/version"

Gem::Specification.new do |s|
  s.name        = "marketo"
  s.version     = Marketo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Kelly"]
  s.email       = ["john@backupify.com"]
  s.homepage    = ""
  s.summary     = %q{Gem for interacting with the Marketo SOAP API}
  s.description = %q{Gem for interacting with the Marketo SOAP API}

  s.rubyforge_project = "marketo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('savon')
  s.add_dependency('savon_model')
  s.add_development_dependency('vcr')
  s.add_development_dependency('rspec')
  s.add_development_dependency('webmock')
end
