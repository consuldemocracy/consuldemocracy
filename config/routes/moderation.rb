namespace :moderation do
  root to: "dashboard#index"

  resources :users, only: :index do
    member do
      put :hide
      put :block
    end
  end

  resources :debates, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :proposals, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  namespace :legislation do
    resources :proposals, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end
  end
  resources :comments, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :proposal_notifications, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :administrator_tasks, only: %i[index edit update]

  resources :budget_investments, only: :index, controller: "budgets/investments" do
    put :hide, on: :member
    put :moderate, on: :collection
  end
end
