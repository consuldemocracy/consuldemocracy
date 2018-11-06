resources :related_contents, only: [:create] do
  member do
    put :score_positive
    put :score_negative
  end
end
