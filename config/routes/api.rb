namespace :api do
  resources :proposals, only: [:create, :update]
end
