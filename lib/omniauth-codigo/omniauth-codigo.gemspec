# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require "omniauth-codigo/version"

Gem::Specification.new do |gem|

  gem.name     = "omniauth-codigo"
  gem.version  = OmniAuth::Codigo::VERSION
  gem.authors  = ["S21"]
  gem.email    = ["info@siglo21consultores.com"]
  gem.homepage = "https://github.com/ConsulVa/consul"
  gem.summary  = "Validación de usuarios mediante código."
  gem.description = "Validación de usuarios mediante código."

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-codigo"
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'httparty'
    

end
