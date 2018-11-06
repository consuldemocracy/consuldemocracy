namespace :valuation do
  root to: "budgets#index"

  resources :spending_proposals, only: [:index, :show, :edit] do
    patch :valuate, on: :member
  end

  resources :budgets, only: :index do
    resources :budget_investments, only: [:index, :show, :edit] do
      patch :valuate, on: :member
    end
  end
end
