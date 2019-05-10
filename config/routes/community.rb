resources :communities, only: [:show] do
  resources :topics
end
