Rails.application.routes.draw do

  mount Ckeditor::Engine => "/ckeditor"

  if Rails.env.development? || Rails.env.staging?
    get "/sandbox" => "sandbox#index"
    get "/sandbox/*template" => "sandbox#show"
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  draw :account
  draw :admin
  draw :annotation
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

  # More info pages
  get "help",             to: "pages#show", id: "help/index",             as: "help"
  get "help/how-to-use",  to: "pages#show", id: "help/how_to_use/index",  as: "how_to_use"
  get "help/faq",         to: "pages#show", id: "faq",                    as: "faq"

  # Static pages
  resources :pages, path: "/", only: [:show]

  # Custom More info
  get 'more-information/debates',             to: 'pages#show', id: 'more_info/_debates',             as: 'more_info/debates'
  get 'more-information/budgets',             to: 'pages#show', id: 'more_info/_budgets',             as: 'more_info/_budgets'
  get 'more-information/proposals',           to: 'pages#show', id: 'more_info/_proposals',           as: 'more_info/_proposals'
  get 'more-information/polls',               to: 'pages#show', id: 'more_info/_polls',               as: 'more_info/_polls'
  get 'more-information/others',              to: 'pages#show', id: 'more_info/_other',               as: 'more_info/_other'
end
