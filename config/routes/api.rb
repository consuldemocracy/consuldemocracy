namespace :api do
  resources :proposals, only: [:index, :show, :create, :update] do
    member do
      post :vote
      patch :retire
      patch :publish
    end
  end
end
