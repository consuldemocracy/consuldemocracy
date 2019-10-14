$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "consul_assemblies/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "consul_assemblies"
  s.version     = ConsulAssemblies::VERSION
  s.authors     = ["Strings Digital"]
  s.email       = ["pedro.leon@wearestrings.com"]
  s.homepage    = "http://github.com/wearestrings/consul"
  s.summary     = "Consul Assemblies allows a new feature to create and manage assemblies in Consul"
  s.description = "This engine will extend a consul instance (up to release 0.12) with assemblies feature"
  s.license     = "AFFERO GPL v3"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.8"
  s.add_dependency "cancancan"
  s.add_dependency "kaminari"

  s.add_development_dependency "sqlite3"
end
