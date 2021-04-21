resources :users, only: [:show, :edit, :update] do
  resources :direct_messages, only: [:new, :create, :show]
end
