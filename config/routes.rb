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

    get 'users/sign_up/success', to: 'users/registrations#success'
    get 'users/registrations/delete_form', to: 'users/registrations#delete_form'
    delete 'users/registrations', to: 'users/registrations#delete'
    get :finish_signup, to: 'users/registrations#finish_signup'
    patch :do_finish_signup, to: 'users/registrations#do_finish_signup'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get '/welcome', to: 'welcome#welcome'
  get '/highlights', to: 'welcome#highlights', as: :highlights


  resources :debates do
    member do
      post :vote
      put :flag
      put :unflag
    end
  end

  resources :proposals do
    member do
      post :vote
      post :vote_featured
      put :flag
      put :unflag
    end
  end

  resources :comments, only: :create, shallow: true do
    member do
      post :vote
      put :flag
      put :unflag
    end
  end

  resources :annotations

  resources :users, only: [:show]

  resource :account, controller: "account", only: [:show, :update, :delete] do
    collection { get :erase }
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
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # static pages
  get "/census_terms", to: "pages#census_terms"
  get "/conditions", to: "pages#conditions"
  get "/general_terms", to: "pages#general_terms"
  get "/privacy", to: "pages#privacy"
  get "/coming_soon", to: "pages#coming_soon"
  get "/how_it_works", to: "pages#how_it_works"
  get "/how_to_use", to: "pages#how_to_use"
  get "/more_information", to: "pages#more_information"
  get "/opendata", to: "pages#opendata"
  get "/participation", to: "pages#participation"
  get "/transparency", to: "pages#transparency"
  get "/proposals_info", to: "pages#proposals_info"
  get "/participation_facts", to: "pages#participation_facts"
  get "/participation_world", to: "pages#participation_world"
  get "/faq", to: "pages#faq"
  get "/blog", to: "pages#blog"
  get "/accessibility", to: "pages#accessibility"
  get "/verifica", to: "verification/letter#edit"
end
