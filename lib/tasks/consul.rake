namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:rename_setting_keys",
                               "settings:add_new_settings",
                               "cache:clear",
                               "execute_release_2.6.0_tasks"]

  desc "Runs tasks needed to upgrade from 2.5.1 to 2.6.0"
  task "execute_release_2.6.0_tasks": [
    "votes:remove_duplicate_votes"
  ]

  desc "Runs tasks needed to upgrade from 2.4.1 to 2.5.1"
  task "execute_release_2.5.1_tasks": []
end
