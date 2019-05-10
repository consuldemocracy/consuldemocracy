resources :documents, only: [:new, :create, :destroy] do
  collection do
    get :new_nested
    delete :destroy_upload
    post :upload
  end
end
