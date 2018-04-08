namespace :officing do
  resources :polls, only: [:index] do
    get :final, on: :collection
    resources :results, only: [:new, :create, :index]
  end

  resource :residence, controller: "residence", only: [:new, :create]
  resources :voters, only: [:new, :create]
  root to: "dashboard#index"
end
