ConsulAssemblies::Engine.routes.draw do



  resources :proposals
  resources :meetings
  resources :assemblies

  namespace :admin do

    resources :assembly_types
    resources :assemblies
    resources :meetings do
      get 'act', on: :member
      get 'draft', on: :member
    end
    resources :proposals do
      get 'up', on: :member
      get 'down', on: :member
    end

  end

end
