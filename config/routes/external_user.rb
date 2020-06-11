resources :external_user, only: [:authorize] do
  collection do
    post :authorize
  end
end
