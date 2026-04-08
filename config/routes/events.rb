# events routes
resources :events, only: [:index, :show]

namespace :admin do
  resources :events
end
