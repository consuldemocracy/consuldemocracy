namespace :dashboard do
  resources :resources, only: [:index]
end

resources :proposals do
  resources :dashboard, only: [:index] do
    collection do
      patch :publish
      get :supports
      get :successful_supports
      get :progress
      get :community
      get :achievements
    end

    member do
      post :execute
      get :new_request
      post :create_request
    end
  end

  namespace :dashboard do
    resources :polls, except: [:show, :destroy]
    resources :mailing, only: [:index, :new, :create]
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
