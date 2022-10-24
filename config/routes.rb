Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  if Rails.env.development? || Rails.env.staging?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end
  # devise_for :users, controllers: {
  #                      registrations: 'users/registrations',
  #                      sessions: 'users/sessions',
  #                      confirmations: 'users/confirmations',
  #                      omniauth_callbacks: 'users/omniauth_callbacks'
  #                    }
  # devise_for :organizations, class_name: 'User',
  #            controllers: {
  #              registrations: 'organizations/registrations',
  #              sessions: 'devise/sessions',
  #            },
  #            skip: [:omniauth_callbacks]
  #
  # devise_scope :organization do
  #   get 'organizations/sign_up/success', to: 'organizations/registrations#success'
  # end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development? || Rails.env.staging?

  draw :custom
  draw :account
  draw :admin
  draw :budget
  draw :comment
  draw :community
  draw :debate
  draw :devise
  draw :direct_upload
  draw :document
  draw :graphql
  draw :legislation
  draw :management
  draw :moderation
  draw :notification
  draw :officing
  draw :poll
  draw :proposal
  draw :related_content
  draw :sdg
  draw :sdg_management
  draw :tag
  draw :user
  draw :valuation
  draw :verification

  root "welcome#index"
  get "/welcome", to: "welcome#welcome"
  get "/consul.json", to: "installation#details"


  resources :stats, only: [:index]
  resources :images, only: [:destroy]
  resources :documents, only: [:destroy]
  resources :follows, only: [:create, :destroy]
  resources :remote_translations, only: [:create]


  # more info pages
  get 'more-information',                     to: 'pages#show', id: 'more_info/index',                as: 'more_info'
  # get 'more-information/how-to-use',          to: 'pages#show', id: 'more_info/how_to_use/index',     as: 'how_to_use'
  # get 'more-information/faq',                 to: 'pages#show', id: 'more_info/faq/index',            as: 'faq'
  # More info pages
  get "help",             to: "pages#show", id: "help/index",             as: "help"
  get "help/how-to-use",  to: "pages#show", id: "help/how_to_use/index",  as: "how_to_use"
  get "help/faq",         to: "pages#show", id: "faq",                    as: "faq"

  # Static pages
  get '/blog' => redirect("http://blog.consul/")

  resources :pages, path: '/', only: [:show]

  get 'presupuestos-participativos-resultados',   to: 'spending_proposals#results', as: 'participatory_budget_results'
  get 'presupuestos-participativos-estadisticas', to: 'spending_proposals#stats',   as: 'participatory_budget_stats'
end
