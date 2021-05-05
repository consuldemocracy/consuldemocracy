resources :users, only: [:show] do
  resources :direct_messages, only: [:new, :create, :show]
end
