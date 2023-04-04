require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    # Change this code when you'd like to add settings that aren't
    # already present in the database. These settings will be added when
    # first installing CONSUL, when deploying code with Capistrano, or
    # when manually executing the `settings:add_new_settings` task.
    #
    # If a setting already exists in the database, changing its value in
    # this file will have no effect unless the task `rake db:seed` is
    # invoked or the method `Setting.reset_defaults` is executed. Doing
    # so will overwrite the values of all existing settings in the
    # database, so use with care.
    #
    # The tests in the spec/ folder rely on CONSUL's default settings, so
    # it's recommended not to change the default settings in the test
    # environment.
    def defaults
      if Rails.env.test?
        consul_defaults
      else
        consul_defaults.merge({
          # Overwrite default CONSUL settings or add new settings here
          "cosla_feature.openai": true,
          "cosla_feature.header": false,
          "cosla_feature.govnotify": false,
          # Enable openai moderation. Requires api key from openai and ruby-openai gem
          "cosla_setting.openai_moderation_api_key": "",
          # openai moderation setting,
          "cosla_setting.openai_moderation_threshhold": "1.5",
          "cosla_setting.govnotify_api_key":"",
          # api key for gov notify service,
          "cosla_setting.openai_moderation.test":"A very bad phrase"
                })
      end
    end
  end
end
