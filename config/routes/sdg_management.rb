namespace :sdg_management do
  root to: "goals#index"

  resources :goals, only: [:index]
end
