Rails.application.routes.draw do
  get 'phone_contact/index'
  get 'user/:id/edit', to: 'users#change', as: 'edit_user'
  resources :projects
  get '/projects/:id/users', to: 'projects#users', as: 'users_project'
  get 'send/index'
  mount Ckeditor::Engine => "/ckeditor"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  resources :users, only: [:edit]
  patch 'users/:id', to: 'users#update'
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
  draw :sdg
  draw :sdg_management
  draw :tag
  draw :user
  draw :valuation
  draw :verification

  root "welcome#index"
  get "/welcome", to: "welcome#welcome"
  get "/recognitions", to: "welcome#recomendations"
  get "/info", to: "welcome#info"
  get "/faq_page", to: "welcome#faq_page"
  get "/consul.json", to: "installation#details"
  get "send" => "send#index"
  post "send" => "send#create"
  get "contact" => "phone_contact#index"
  post "contact" => "phone_contact#create"
  get "privacy_policy" => "welcome#privacy_policy"

  resources :stats, only: [:index]
  resources :images, only: [:destroy]
  resources :documents, only: [:destroy]
  resources :follows, only: [:create, :destroy]
  resources :remote_translations, only: [:create]

  # More info pages
  get "help",             to: "pages#show", id: "help/index",             as: "help"
  get "help/how-to-use",  to: "pages#show", id: "help/how_to_use/index",  as: "how_to_use"
  get "help/faq",         to: "pages#show", id: "faq",                    as: "faq"

  # Static pages
  resources :pages, path: "/", only: [:show]

end
