# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-ldap/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ping Yu"]
  gem.email         = ["ping@intridea.com"]
  gem.description   = %q{A LDAP strategy for OmniAuth.}
  gem.summary       = %q{A LDAP strategy for OmniAuth.}
  gem.homepage      = "https://github.com/intridea/omniauth-ldap"
  gem.license       = "MIT"

  gem.add_runtime_dependency     'omniauth', '~> 1.0'
  gem.add_runtime_dependency     'net-ldap', '~> 0.12'
  gem.add_runtime_dependency     'pyu-ruby-sasl', '~> 0.0.3.2'#0.0.3.1 has been yanked
  gem.add_runtime_dependency     'rubyntlm', '~> 0.3.4'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'libnotify'
  gem.add_development_dependency 'ruby-debug19'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-ldap"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::LDAP::VERSION
end
