resources :polls, only: [:show, :index] do
  member do
    get :stats
    get :results
  end

  resources :questions, controller: "polls/questions", shallow: true, only: [] do
    resources :answers, controller: "polls/answers", only: [:create, :destroy], shallow: false
  end
end
