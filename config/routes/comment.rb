resources :comments, only: [:create, :show] do
  member do
    post :vote
    put :flag
    put :unflag
    put :hide
  end
end
