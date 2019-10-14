require "rails"
require "active_support/all"

module ConsulAssemblies
  class Engine < ::Rails::Engine
    isolate_namespace ConsulAssemblies
  end
end
