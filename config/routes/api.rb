namespace :api do
  resources :proposals, only: [:create]
end
