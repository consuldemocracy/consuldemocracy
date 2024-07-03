resources :polls, only: [:show, :index] do
  member do
    get :stats
    get :results
    post :answer
  end
end

resolve "Poll::Question" do |question, options|
  [:question, options.merge(id: question)]
end
