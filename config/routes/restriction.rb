namespace :restriction do
  root to: "dashboard#index"

  resources :locked_users, only: [:index, :create, :show, :preview] do
    post :preview, on: :collection
  end
end
