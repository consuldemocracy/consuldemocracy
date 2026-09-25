namespace :api do
  resources :proposals, only: [:create, :update] do
    member do
      post :vote
      patch :retire
      patch :publish
    end
  end
end
