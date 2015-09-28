module FlagActions
  extend ActiveSupport::Concern

  def flag
    Flag.flag(current_user, flagable)
    respond_with flagable, template: "#{controller_name}/_refresh_flag_actions"
  end

  def unflag
    Flag.unflag(current_user, flagable)
    respond_with flagable, template: "#{controller_name}/_refresh_flag_actions"
  end

  private

    def flagable
      instance_variable_get("@#{controller_name.singularize}")
    end

end