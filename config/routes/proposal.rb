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
    put 'recommendations/disable', only: :index, controller: 'proposals', action: :disable_recommendations
  end
end
