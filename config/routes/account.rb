resource :account, controller: "account", only: [:show, :update, :delete] do
  get :erase, on: :collection
  delete "remove-provider/:id", as: :remove_provider, action: :remove_provider, on: :member # route custom
end
