namespace :communication do
  root to: "tags#index"

  resources :tags, only: [:index, :create, :update, :destroy]

  # resources :budgets, only: :index do
  #   resources :budget_investments, only: [:index, :show, :edit] do
  #     patch :valuate, on: :member
  #   end
  # end
end