module FlagActions
  extend ActiveSupport::Concern

  def flag
    Flag.flag(current_user, flaggable)
    respond_with flaggable, template: "#{controller_name}/_refresh_flag_actions"
  end

  def unflag
    Flag.unflag(current_user, flaggable)
    respond_with flaggable, template: "#{controller_name}/_refresh_flag_actions"
  end

  private

    def flaggable
      instance_variable_get("@#{resource_model.to_s.downcase}")
    end

end