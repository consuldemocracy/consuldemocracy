namespace :sdg do
  resources :goals, param: :code, only: [:index, :show]
end
