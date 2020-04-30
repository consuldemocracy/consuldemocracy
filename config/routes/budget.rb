resources :budgets, only: [:show, :index] do
  resources :groups, controller: "budgets/groups", only: [:index, :show]
  resources :investments, controller: "budgets/investments" do
    member do
      post :vote
      put :flag
      put :unflag
    end

    collection { get :suggest }
  end

  resource :ballot, only: :show, controller: "budgets/ballots" do
    resources :lines, controller: "budgets/ballot/lines", only: [:create, :destroy]
  end

  resource :results, only: :show, controller: "budgets/results"
  resource :stats, only: :show, controller: "budgets/stats"
  resource :executions, only: :show, controller: "budgets/executions"
end

get "investments/:id/json_data", action: :json_data, controller: "budgets/investments"
get "/budgets/:budget_id/investments/:id/json_data", action: :json_data, controller: "budgets/investments"
