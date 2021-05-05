resources :users, only: [:show,:edit] do
  resources :direct_messages, only: [:new, :create, :show]
end
