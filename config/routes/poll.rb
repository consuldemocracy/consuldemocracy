resources :polls, only: [:show, :index] do
  member do
    get :stats
    get :results
  end

  resources :questions, controller: "polls/questions", shallow: true do
    member do
      post :answer
      post :prioritized_answers
      delete :answer, to: "polls/answers#delete"
      post :create_answer, to: "polls/answers#create"
      get :load_answers
    end
  end
end
