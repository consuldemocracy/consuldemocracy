namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:rename_setting_keys",
                               "settings:add_new_settings",
                               "cache:clear",
                               "execute_release_2.4.0_tasks"]

  desc "Runs tasks needed to upgrade from 2.3.1 to 2.4.0"
  task "execute_release_2.4.0_tasks": [
    "polls:populate_partial_results_option_id"
  ]
end
