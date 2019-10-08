namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: "execute_release_1.0.0_tasks"

  desc "Runs tasks needed to upgrade from 1.0.0-beta to 1.0.0"
  task "execute_release_1.0.0_tasks": [
    "settings:remove_deprecated_settings",
    "settings:rename_setting_keys",
    "settings:add_new_settings",
    "stats:generate"
  ]
end
