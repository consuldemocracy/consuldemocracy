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
    end
  end
end

resolve "Poll::Question" do |question, options|
  [:question, options.merge(id: question)]
end
