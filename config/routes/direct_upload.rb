resources :direct_uploads, only: [:create]
delete "direct_uploads/destroy", to: "direct_uploads#destroy", as: :direct_upload_destroy
