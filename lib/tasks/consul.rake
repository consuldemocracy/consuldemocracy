namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:rename_setting_keys",
                               "settings:add_new_settings",
                               "execute_release_1.4.0_tasks"]

  desc "Runs tasks needed to upgrade from 1.3.0 to 1.4.0"
  task "execute_release_1.4.0_tasks": [
    "active_storage:migrate_from_paperclip"
  ]

  desc "Runs tasks needed to upgrade from 1.2.0 to 1.3.0"
  task "execute_release_1.3.0_tasks": [
    "db:load_sdg",
    "db:calculate_tsv",
    "budgets:set_published",
    "budgets:phases_summary_to_description",
    "budgets:add_name_to_existing_phases"
  ]
end
