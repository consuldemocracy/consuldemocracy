namespace :tracking do
  root to: "budgets#index"

  resources :budgets, only: :index do
    resources :budget_investments, only: [:index, :show, :edit] do
      resources :milestones, controller: "budget_investment_milestones"
      resources :progress_bars, except: :show, controller: "budget_investment_progress_bars"
      patch :track, on: :member
    end
  end

  resources :proposals, only: [:index, :show] do
    resources :milestones, controller: "proposal_milestones"
    resources :progress_bars, except: :show, controller: "proposal_progress_bars"
  end

  namespace :legislation do
    resources :processes, only: [:index, :show] do
      resources :milestones
      resources :progress_bars, except: :show
    end
  end
end
