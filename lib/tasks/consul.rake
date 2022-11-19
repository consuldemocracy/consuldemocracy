namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:rename_setting_keys",
                               "settings:add_new_settings",
                               "execute_release_1.6.0_tasks"]

  desc "Runs tasks needed to upgrade from 1.5.0 to 1.6.0"
  task "execute_release_1.6.0_tasks": [
    "db:calculate_tsv",
    "polls:set_ends_at_to_end_of_day",
    "db:add_schema_search_path"
  ]
end
