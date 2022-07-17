namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:rename_setting_keys",
                               "settings:add_new_settings",
                               "execute_release_1.5.0_tasks"]

  desc "Runs tasks needed to upgrade from 1.4.0 to 1.5.0"
  task "execute_release_1.5.0_tasks": [
    "active_storage:remove_paperclip_compatibility_in_existing_attachments"
  ]
end
