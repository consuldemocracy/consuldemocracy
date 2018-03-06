resources :articles, path: '/news', only: [:index, :show]

namespace :admin do
  resources :articles,
    path: '/news',
    only: [:index, :new, :create, :edit, :update, :show, :destroy]
end
