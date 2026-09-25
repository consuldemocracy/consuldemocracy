namespace :api do
  resources :proposals, only: [:create, :update] do
    member do
      patch :retire
      patch :publish
    end
  end
end
