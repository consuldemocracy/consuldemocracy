resources :notifications, only: [:index, :show] do
  put :mark_as_read, on: :member
  put :mark_all_as_read, on: :collection
  put :mark_as_unread, on: :member
  get :read, on: :collection
end

resources :proposal_notifications, only: [:new, :create, :show]
