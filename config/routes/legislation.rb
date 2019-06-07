namespace :legislation do
  resources :processes, only: [:index, :show] do
    member do
      get :debate
      get :draft_publication
      get :allegations
      get :result_publication
      get :proposals
      get :milestones
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
