namespace :moderation do
  root to: "dashboard#index"

  resources :users, only: :index do
    member do
      put :hide
      put :hide_in_moderation_screen
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

  resources :comments, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :proposal_notifications, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :budget_investments, only: :index, controller: 'budgets/investments' do
    put :hide, on: :member
    put :moderate, on: :collection
  end
end
