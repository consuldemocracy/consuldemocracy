namespace :api do
  resources :proposals, only: [:show, :create, :update] do
    member do
      post :vote
      patch :retire
      patch :publish
    end
  end
end
