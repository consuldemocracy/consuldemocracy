resources :notifications, only: [:index, :show] do
  put :mark_all_as_read, on: :collection
end

resources :proposal_notifications, only: [:new, :create, :show]
