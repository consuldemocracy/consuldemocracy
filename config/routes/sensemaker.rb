namespace :sensemaker do
  get "processes/:process_id/jobs", to: "jobs#index", as: :legislation_process_jobs
  get "budgets/:budget_id/jobs", to: "jobs#index", as: :budget_jobs
  resources :jobs, only: [:show] do
    get "artefacts/report", on: :member, to: "jobs#serve_report", as: :serve_report
    get "artefacts/comments", on: :member, to: "jobs#serve_comments", as: :serve_comments
    get "artefacts/summary", on: :member, to: "jobs#serve_summary", as: :serve_summary
    get "artefacts/topic-stats", on: :member, to: "jobs#serve_topic_stats", as: :serve_topic_stats
  end
end
