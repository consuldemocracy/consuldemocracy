namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:add_new_settings", "execute_release_1.2.0_tasks"]

  desc "Runs tasks needed to upgrade from 1.0.0 to 1.1.0"
  task "execute_release_1.1.0_tasks": [
    "budgets:set_original_heading_id",
    "migrations:valuation_taggings",
    "migrations:budget_admins_and_valuators"
  ]

  desc "Runs tasks needed to upgrade from 1.1.0 to 1.2.0"
  task "execute_release_1.2.0_tasks": [
    "budgets:update_drafting_budgets",
    "migrations:add_name_to_existing_budget_phases",
    "migrations:budget_phases_summary_to_description"
  ]
end
