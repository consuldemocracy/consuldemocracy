namespace :management do
  root to: "dashboard#index"

  resources :document_verifications, only: [:index, :new, :create] do
    post :check, on: :collection
  end

  resources :email_verifications, only: [:new, :create]
  resources :user_invites, only: [:new, :create]

  resources :users, only: [:new, :create] do
    collection do
      delete :logout
      delete :erase
    end
  end

  resource :account, controller: "account", only: [:show] do
    get :print_password
    patch :change_password
    get :reset_password
    get :edit_password_email
    get :edit_password_manually
  end

  resource :session, only: [:create, :destroy]
  get "sign_in", to: "sessions#create", as: :sign_in

  resources :proposals, only: [:index, :new, :create, :show] do
    post :vote, on: :member
    get :print, on: :collection
  end

  resources :budgets, only: :index do
    collection do
      get :create_investments
      get :support_investments
      get :print_investments
    end

    resources :investments, only: [:index, :new, :create, :show, :destroy], controller: "budgets/investments" do
      get :print, on: :collection

      resources :votes, controller: "budgets/investments/votes", only: [:create, :destroy]
    end
  end
end
