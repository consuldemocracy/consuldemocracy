class Admin::BudgetInvestments::SearchFormComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "admin", "budget_investments", "search_form_component.rb")

class Admin::BudgetInvestments::SearchFormComponent
  # Filter by created before and after

  private

    def advanced_menu_visibility
      if advanced_filters_params.empty? &&
         params["created_before"].blank? &&
         params["created_after"].blank? &&
         params["min_total_supports"].blank? &&
         params["max_total_supports"].blank? &&
         params["enough_support"].blank?
        "hide"
      else
        ""
      end
    end
end
