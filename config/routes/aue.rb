namespace :aue do
  resources :goals, param: :code, only: [:index, :show]
  get :help, controller: "goals"
end
