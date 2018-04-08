resources :comments, only: [:create, :show], shallow: true do
  member do
    post :vote
    put :flag
    put :unflag
  end
end
