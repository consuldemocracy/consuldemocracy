namespace :legislation do
  resources :processes, only: [:index, :show] do
    member do
      get :debate
      get :draft_publication
      get :allegations
      get :result_publication
      get :proposals
      get :milestones
      get :summary
    end

    resources :questions, only: [:show] do
      resources :answers, only: [:create]
    end

    resources :proposals, except: [:index] do
      member do
        put :flag
        put :unflag
      end
      collection do
        get :suggest
      end
    end

    resources :legislation_proposals, path: "proposals", only: [] do
      resources :votes, controller: "proposals/votes", only: [:create, :destroy]
    end

    resources :draft_versions, only: [:show] do
      get :go_to_version, on: :collection
      get :changes
      resources :annotations do
        get :search, on: :collection
        get :comments
        post :new_comment
      end
    end
  end
end

resolve "Legislation::Proposal" do |proposal, options|
  [proposal.process, :proposal, options.merge(id: proposal)]
end

resolve "Vote" do |vote, options|
  [*resource_hierarchy_for(vote.votable), vote, options]
end

resolve "Legislation::Question" do |question, options|
  [question.process, :question, options.merge(id: question)]
end

resolve "Legislation::Annotation" do |annotation, options|
  [annotation.draft_version.process, :draft_version, :annotation,
   options.merge(draft_version_id: annotation.draft_version, id: annotation)]
end
