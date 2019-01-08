module FlagActions
  extend ActiveSupport::Concern

  def flag
    Flag.flag(current_user, flaggable)

    if controller_name == 'investments'
      respond_with flaggable, template: "budgets/#{controller_name}/_refresh_flag_actions"
    else
      respond_with flaggable, template: "#{controller_name}/_refresh_flag_actions"
    end
  end

  def unflag
    Flag.unflag(current_user, flaggable)

    if controller_name == 'investments'
      respond_with flaggable, template: "budgets/#{controller_name}/_refresh_flag_actions"
    else
      respond_with flaggable, template: "#{controller_name}/_refresh_flag_actions"
    end
  end

  private

    def flaggable
      if resource_model.to_s == 'Budget::Investment'
        instance_variable_get("@investment")
      else
        instance_variable_get("@#{resource_model.to_s.downcase}")
      end
    end

end
