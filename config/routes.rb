require "rails/application"

# Añadido modulo para facilitar la gestión de la redirección
# de todas las rutas de la aplicación
module RouteScoper
  def self.root
    Rails.application.config.root_directory
  rescue NameError
    "/"
  end
end

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  mount Ckeditor::Engine => "/ckeditor"

  get "/", to: redirect(Rails.application.config.root_directory)

  scope RouteScoper.root do
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
    resources :remote_translations, only: [:create]

    # More info pages
    get "help",             to: "pages#show", id: "help/index",             as: "help"
    get "help/how-to-use",  to: "pages#show", id: "help/how_to_use/index",  as: "how_to_use"
    get "help/faq",         to: "pages#show", id: "faq",                    as: "faq"

    # Static pages
    resources :pages, path: "/", only: [:show]
  end
end
