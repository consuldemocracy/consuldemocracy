module FlagActions
  extend ActiveSupport::Concern

  def flag
    Flag.flag(current_user, flaggable)

    render "_refresh_flag_actions"
  end

  def unflag
    Flag.unflag(current_user, flaggable)

    render "_refresh_flag_actions"
  end

  private

    def flaggable
      if resource_model.to_s == "Budget::Investment"
        instance_variable_get("@investment")
      elsif resource_model.to_s == "Legislation::Proposal"
        instance_variable_get("@proposal")
      else
        instance_variable_get("@#{resource_model.to_s.downcase}")
      end
    end
end
