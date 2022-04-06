resources :comments, only: [:create, :show], shallow: true do
  member do
    post :vote
    put :flag
    put :unflag
    put :hide
  end
end
