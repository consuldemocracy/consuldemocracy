Rails.application.routes.draw do

  if Rails.env.development? || Rails.env.staging?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  devise_for :organizations, class_name: 'User',
                             controllers: {
                               registrations: 'organizations/registrations',
                               sessions: 'devise/sessions'
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
  get '/cuentasegura', to: 'welcome#verification', as: :cuentasegura

  resources :debates do
    member do
      post :vote
      put :flag
      put :unflag
      put :mark_featured
      put :unmark_featured
    end
    collection do
      get :map
      get :suggest
    end
  end

  resources :proposals do
    member do
      post :vote
      post :vote_featured
      put :flag
      put :unflag
      get :retire_form
      get :share
      patch :retire
    end
    collection do
      get :map
      get :suggest
      get :summary
    end
  end

  resources :comments, only: [:create, :show], shallow: true do
    member do
      post :vote
      put :flag
      put :unflag
    end
  end

  resources :budgets, only: [:show, :index] do
    resources :groups, controller: "budgets/groups", only: [:show]
    resources :investments, controller: "budgets/investments", only: [:index, :new, :create, :show, :destroy] do
      member do
        post :vote
      end
      collection { get :suggest }
    end
    resource :ballot, only: :show, controller: "budgets/ballots" do
      resources :lines, controller: "budgets/ballot/lines", only: [:create, :destroy]
    end
    resource :results, only: :show, controller: "budgets/results"
  end

  scope '/participatory_budget' do
    resources :spending_proposals, only: [:index, :new, :create, :show, :destroy], path: 'investment_projects' do
      post :vote, on: :member
    end
  end

  resources :follows, only: [:create, :destroy]

  resources :documents, only: [:destroy]

  resources :images, only: [:destroy]

  resources :direct_uploads, only: [:create]
  delete "direct_uploads/destroy", to: "direct_uploads#destroy", as: :direct_upload_destroy

  resources :stats, only: [:index]

  resources :legacy_legislations, only: [:show], path: 'legislations'

  resources :annotations do
    get :search, on: :collection
  end

  resources :polls, only: [:show, :index] do
    member do
      get :stats
      get :results
    end
    resources :questions, controller: 'polls/questions', shallow: true do
      post :answer, on: :member
    end
  end

  namespace :legislation do
    resources :processes, only: [:index, :show] do
      member do
        get :debate
        get :draft_publication
        get :allegations
        get :result_publication
        get :proposals
      end
      resources :questions, only: [:show] do
        resources :answers, only: [:create]
      end
      resources :proposals do
        member do
          post :vote
          put :flag
          put :unflag
        end
        collection do
          get :map
          get :suggest
        end
      end
      resources :draft_versions, only: [:show] do
        get :go_to_version, on: :collection
        get :changes
        resources :annotations do
          get :search, on: :collection
          get :comments
          post :new_comment
        end
      end
    end
  end

  resources :users, only: [:show] do
    resources :direct_messages, only: [:new, :create, :show]
  end

  resource :account, controller: "account", only: [:show, :update, :delete] do
    get :erase, on: :collection
  end

  resources :notifications, only: [:index, :show] do
    put :mark_all_as_read, on: :collection
  end

  resources :proposal_notifications, only: [:new, :create, :show]

  resource :verification, controller: "verification", only: [:show]

  resources :communities, only: [:show] do
    resources :topics
  end

  scope module: :verification do
    resource :residence, controller: "residence", only: [:new, :create]
    resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
    resource :verified_user, controller: "verified_user", only: [:show]
    resource :email, controller: "email", only: [:new, :show, :create]
    resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
  end

  resources :tags do
    collection do
      get :suggest
    end
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :organizations, only: :index do
      get :search, on: :collection
      member do
        put :verify
        put :reject
      end
    end

    resources :hidden_users, only: [:index, :show] do
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

    resources :spending_proposals, only: [:index, :show, :edit, :update] do
      member do
        patch :assign_admin
        patch :assign_valuators
      end

      get :summary, on: :collection
    end

    resources :budgets do
      member do
        put :calculate_winners
      end

      resources :budget_groups do
        resources :budget_headings do
        end
      end

      resources :budget_investments, only: [:index, :show, :edit, :update] do
        resources :budget_investment_milestones
        member { patch :toggle_selection }
      end
    end

    resources :signature_sheets, only: [:index, :new, :create, :show]

    resources :banners, only: [:index, :new, :create, :edit, :update, :destroy] do
      collection { get :search}
    end

    resources :comments, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :tags, only: [:index, :create, :update, :destroy]
    resources :officials, only: [:index, :edit, :update, :destroy] do
      get :search, on: :collection
    end

    resources :settings, only: [:index, :update]
    put :update_map, to: "settings#update_map"

    resources :moderators, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :valuators, only: [:index, :create] do
      get :search, on: :collection
      get :summary, on: :collection
    end

    resources :managers, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :administrators, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :users, only: [:index, :show]

    scope module: :poll do
      resources :polls do
        get :booth_assignments, on: :collection
        patch :add_question, on: :member

        resources :booth_assignments, only: [:index, :show, :create, :destroy] do
          get :search_booths, on: :collection
          get :manage, on: :collection
        end

        resources :officer_assignments, only: [:index, :create, :destroy] do
          get :search_officers, on: :collection
          get :by_officer, on: :collection
        end

        resources :recounts, only: :index
        resources :results, only: :index
      end

      resources :officers do
        get :search, on: :collection
      end

      resources :booths do
        get :available, on: :collection

        resources :shifts do
          get :search_officers, on: :collection
        end
      end

      resources :questions, shallow: true do
        resources :answers, except: [:index, :destroy], controller: 'questions/answers', shallow: true do
          resources :images, controller: 'questions/answers/images'
          resources :videos, controller: 'questions/answers/videos'
          get :documents, to: 'questions/answers#documents'
        end
        post '/answers/order_answers', to: 'questions/answers#order_answers'
      end
    end

    resources :verifications, controller: :verifications, only: :index do
      get :search, on: :collection
    end

    resource :activity, controller: :activity, only: :show
    resources :newsletters, only: :index do
      get :users, on: :collection
    end
    resource :stats, only: :show do
      get :proposal_notifications, on: :collection
      get :direct_messages, on: :collection
    end

    namespace :legislation do
      resources :processes do
        resources :questions
        resources :proposals
        resources :draft_versions
      end
    end

    namespace :api do
      resource :stats, only: :show
    end

    resources :geozones, only: [:index, :new, :create, :edit, :update, :destroy]

    namespace :site_customization do
      resources :pages, except: [:show]
      resources :images, only: [:index, :update, :destroy]
      resources :content_blocks, except: [:show]
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
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :proposals, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :comments, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end
  end

  namespace :valuation do
    root to: "budgets#index"

    resources :spending_proposals, only: [:index, :show, :edit] do
      patch :valuate, on: :member
    end

    resources :budgets, only: :index do
      resources :budget_investments, only: [:index, :show, :edit] do
        patch :valuate, on: :member
      end
    end
  end

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

    resource :account, controller: "account", only: [:show]

    get 'sign_in', to: 'sessions#create', as: :sign_in

    resource :session, only: [:create, :destroy]
    resources :proposals, only: [:index, :new, :create, :show] do
      post :vote, on: :member
      get :print, on: :collection
    end

    resources :spending_proposals, only: [:index, :new, :create, :show] do
      post :vote, on: :member
      get :print, on: :collection
    end

    resources :budgets, only: :index do
      collection do
        get :create_investments
        get :support_investments
        get :print_investments
      end
      resources :investments, only: [:index, :new, :create, :show, :destroy], controller: 'budgets/investments' do
        post :vote, on: :member
        get :print, on: :collection
      end
    end
  end

  namespace :officing do
    resources :polls, only: [:index] do
      get :final, on: :collection

      resources :results, only: [:new, :create, :index]
    end
    resource :residence, controller: "residence", only: [:new, :create]
    resources :voters, only: [:new, :create]
    root to: "dashboard#index"
  end

  # GraphQL
  get '/graphql', to: 'graphql#query'
  post '/graphql', to: 'graphql#query'

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'

  # more info pages
  get 'more-information',                     to: 'pages#show', id: 'more_info/index',                as: 'more_info'
  get 'more-information/how-to-use',          to: 'pages#show', id: 'more_info/how_to_use/index',     as: 'how_to_use'
  get 'more-information/faq',                 to: 'pages#show', id: 'more_info/faq/index',            as: 'faq'

  # static pages
  get '/blog' => redirect("http://blog.consul/")
  resources :pages, path: '/', only: [:show]
end
