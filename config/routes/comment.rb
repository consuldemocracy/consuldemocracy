resources :comments, only: [:create, :show] do
  member do
    put :flag
    put :unflag
    put :hide
  end

  resources :votes, controller: "comments/votes", only: :create
end
