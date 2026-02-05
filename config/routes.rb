Rails.application.routes.draw do
  mount Ckeditor::Engine => "/ckeditor"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  draw :custom

  draw :account
  draw :admin
  draw :devise

  constraints lambda { |request| Rails.application.multitenancy_management_mode? } do
    get "/", to: "admin/tenants#index"
  end

  constraints lambda { |request| !Rails.application.multitenancy_management_mode? } do
    draw :budget
    draw :comment
    draw :community
    draw :debate
    draw :direct_upload
    draw :document
    draw :graphql
    draw :legislation
    draw :management
    draw :moderation
    draw :notification
    draw :officing
    draw :poll
    draw :proposal
    draw :related_content
    draw :sdg
    draw :sdg_management
    draw :sensemaker
    draw :tag
    draw :user
    draw :valuation
    draw :verification

    root "welcome#index"
    get "/welcome", to: "welcome#welcome"
    get "/consul.json", to: "installation#details"
    get "robots.txt", to: "robots#index"

    resources :images, only: [:destroy]
    resources :documents, only: [:destroy]
    resources :follows, only: [:create, :destroy]
    resources :remote_translations, only: [:create]

    # More info pages
    get "help",             to: "pages#show", id: "help/index",             as: "help"
    get "help/how-to-use",  to: "pages#show", id: "help/how_to_use/index",  as: "how_to_use"
    get "help/faq",         to: "pages#show", id: "faq",                    as: "faq"

    # Static pages
    resources :pages, path: "/", only: [:show]
  end

  resolve "Budget::Investment" do |investment, options|
    [investment.budget, :investment, options.merge(id: investment)]
  end

  resolve("Topic") { |topic, options| [topic.community, topic, options] }

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

  resolve "Poll::Question" do |question, options|
    [:question, options.merge(id: question)]
  end

  resolve "SDG::LocalTarget" do |target, options|
    [:local_target, options.merge(id: target)]
  end
end
