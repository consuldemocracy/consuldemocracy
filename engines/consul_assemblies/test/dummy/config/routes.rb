Rails.application.routes.draw do

  mount ConsulAssemblies::Engine => "/consul_assemblies"
end
