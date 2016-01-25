Rails.application.routes.draw do

  devise_for :users, controllers: {
                       registrations: 'users/registrations',
                       sessions: 'users/sessions',
                       confirmations: 'users/confirmations',
                       omniauth_callbacks: 'users/omniauth_callbacks'
                     }
  devise_for :organizations, class_name: 'User',
             controllers: {
               registrations: 'organizations/registrations',
               sessions: 'devise/sessions',
             },
             skip: [:omniauth_callbacks]

  devise_scope :organization do
    get 'organizations/sign_up/success', to: 'organizations/registrations#success'
  end

  devise_scope :user do
    patch '/user/confirmation', to: 'users/confirmations#update', as: :update_user_confirmation
    get '/user/registrations/check_username', to: 'users/registrations#check_username'
    get 'users/sign_up/success', to: 'users/registrations#success'
    get 'users/registrations/delete_form', to: 'users/registrations#delete_form'
    delete 'users/registrations', to: 'users/registrations#delete'
    get :finish_signup, to: 'users/registrations#finish_signup'
    patch :do_finish_signup, to: 'users/registrations#do_finish_signup'
  end

  root 'welcome#index'
  get '/welcome', to: 'welcome#welcome'
  get '/highlights', to: 'welcome#highlights', as: :highlights


  resources :debates do
    member do
      post :vote
      put :flag
      put :unflag
    end

    collection do
      get :map
    end
  end

  resources :proposals do
    member do
      post :vote
      post :vote_featured
      put :flag
      put :unflag
    end

    collection do
      get :map
    end
  end

  resources :comments, only: [:create, :show], shallow: true do
    member do
      post :vote
      put :flag
      put :unflag
    end
  end

  resources :spending_proposals, only: [:index, :new, :create]

  resources :legislations, only: [:show]

  resources :annotations do
    collection do
      get :search
    end
  end

  resources :users, only: [:show]

  resource :account, controller: "account", only: [:show, :update, :delete] do
    collection { get :erase }
  end

  resources :notifications, only: [:index, :show] do
    collection { put :mark_all_as_read }
  end

  resource :verification, controller: "verification", only: [:show]

  scope module: :verification do
    resource :residence, controller: "residence", only: [:new, :create]
    resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
    resource :verified_user, controller: "verified_user", only: [:show]
    resource :email, controller: "email", only: [:new, :show, :create]
    resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :organizations, only: :index do
      collection { get :search }
      member do
        put :verify
        put :reject
      end
    end

    resources :users, only: [:index, :show] do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :debates, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :proposals, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :spending_proposals, only: [:index, :show] do
      member do
        put :accept
        put :reject
      end
    end

    resources :comments, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :tags, only: [:index, :create, :update, :destroy]
    resources :officials, only: [:index, :edit, :update, :destroy] do
      collection { get :search}
    end

    resources :settings, only: [:index, :update]
    resources :moderators, only: [:index, :create, :destroy] do
      collection { get :search }
    end

    resources :verifications, controller: :verifications, only: :index do
      collection { get :search}
    end

    resource :activity, controller: :activity, only: :show
    resource :stats, only: :show

    namespace :api do
      resource :stats, only: :show
    end
  end

  namespace :moderation do
    root to: "dashboard#index"

    resources :users, only: :index do
      member do
        put :hide
        put :hide_in_moderation_screen
      end
    end

    resources :debates, only: :index do
      member do
        put :hide
      end
      collection do
        put :moderate
      end
    end

    resources :proposals, only: :index do
      member do
        put :hide
      end
      collection do
        put :moderate
      end
    end

    resources :comments, only: :index do
      member do
        put :hide
      end
      collection do
        put :moderate
      end
    end
  end

  namespace :management do
    root to: "dashboard#index"

    resources :document_verifications, only: [:index, :new, :create] do
      collection do
        post :check
      end
    end

    resources :email_verifications, only: [:new, :create]

    resources :users, only: [:new, :create] do
      collection do
        delete :logout
      end
    end

    get 'sign_in', to: 'sessions#create'

    resource :session, only: [:create, :destroy]
    resources :proposals, only: [:index, :new, :create, :show] do
      member do
        post :vote
      end

      collection do
        get :print
      end
    end

    resources :spending_proposals, only: [:new, :create, :show]
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount Tolk::Engine => '/translate', :as => 'tolk'

  # static pages
  get '/blog' => redirect("http://diario.madrid.es/participa/")
  resources :pages, path: '/', only: [:show]
end