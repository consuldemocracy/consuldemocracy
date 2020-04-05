namespace :consultation do
  root to: "dashboard#index"

  resources :codes, only: [:index, :check] do 
    post :check, on: :collection
  end
end
