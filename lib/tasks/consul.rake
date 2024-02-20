namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:rename_setting_keys",
                               "settings:add_new_settings",
                               "execute_release_2.1.0_tasks"]

  desc "Runs tasks needed to upgrade from 2.0.1 to 2.1.0"
  task "execute_release_2.1.0_tasks": []
end
