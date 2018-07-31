resources :proposals do
  resources :dashboard, only: [:index] do
    collection do
      patch :publish
      get :progress
      get :community
    end

    member do
      post :execute
      get :new_request
      post :create_request
    end
  end

  namespace :dashboard do
    resources :resources, only: [:index]
    resources :achievements, only: [:index]
    resources :successful_supports, only: [:index]
    resources :supports, only: [:index]
    resources :polls, except: [:show, :destroy]
    resources :mailing, only: [:index, :new, :create]
    resources :poster, only: [:index, :new]
  end

  member do
    post :vote
    post :vote_featured
    put :flag
    put :unflag
    get :retire_form
    get :share
    get :created
    patch :retire
    patch :publish
  end

  collection do
    get :map
    get :suggest
    get :summary
    put 'recommendations/disable', only: :index, controller: 'proposals', action: :disable_recommendations
  end
end
