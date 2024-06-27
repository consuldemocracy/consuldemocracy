namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:rename_setting_keys",
                               "settings:add_new_settings",
                               "cache:clear",
                               "execute_release_2.2.0_tasks"]

  desc "Runs tasks needed to upgrade from 2.1.1 to 2.2.0"
  task "execute_release_2.2.0_tasks": [
    "db:mask_ips",
    "polls:remove_duplicate_voters",
    "polls:populate_option_id"
  ]
end
