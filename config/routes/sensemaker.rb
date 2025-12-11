namespace :sensemaker do
  get "processes/:process_id/jobs", to: "jobs#index", as: :legislation_process_jobs
  get "budgets/:budget_id/jobs", to: "jobs#index", as: :budget_jobs
  resources :jobs, only: [:show] do
    get "artefacts/report", on: :member, to: "jobs#serve_report", as: :serve_report
  end
end
