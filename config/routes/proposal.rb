resources :proposals do
  resource :dashboard, only: [:show], controller: "dashboard" do
    collection do
      patch :publish
      get :progress
      get :community
      get :recommended_actions
      get :messages
      get :related_content
    end

    resources :resources, only: [:index], controller: "dashboard/resources"
    resources :achievements, only: [:index], controller: "dashboard/achievements"
    resources :successful_supports, only: [:index], controller: "dashboard/successful_supports"
    resources :supports, only: [:index], controller: "dashboard/supports"
    resources :polls, except: [:show], controller: "dashboard/polls"
    resources :mailing, only: [:index, :new, :create], controller: "dashboard/mailing"
    resources :poster, only: [:index, :new], controller: "dashboard/poster"
    resources :actions, only: [], controller: "dashboard/actions" do
      member do
        post :execute
        post :unexecute
        get :new_request
        post :create_request
      end
    end
  end

  resources :polls, only: [:show, :results], controller: "polls" do
    member do
      get :results
    end
  end

  member do
    post :vote
    post :un_vote
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
    put "recommendations/disable", only: :index, controller: "proposals", action: :disable_recommendations
  end
end
