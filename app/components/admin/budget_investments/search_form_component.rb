class Admin::BudgetInvestments::SearchFormComponent < ApplicationComponent
  attr_reader :budget
  use_helpers :budget_heading_select_options

  def initialize(budget)
    @budget = budget
  end

  private

    def attribute_name(attribute)
      Budget::Investment.human_attribute_name(attribute)
    end

    def advanced_filters_params
      params[:advanced_filters] ||= []
    end

    def advanced_menu_visibility
      if advanced_filters_params.empty? &&
         params["min_total_supports"].blank? &&
         params["max_total_supports"].blank?
        "hide"
      else
        ""
      end
    end

    def admin_select_options
      budget.administrators.with_user.map { |v| [v.description_or_name, v.id] }.sort_by { |a| a[0] }
    end

    def valuator_or_group_select_options
      valuator_group_select_options + valuator_select_options
    end

    def valuator_group_select_options
      ValuatorGroup.order("name ASC").map { |g| [g.name, "group_#{g.id}"] }
    end

    def valuator_select_options
      budget.valuators.order("description ASC").order("users.email ASC").includes(:user)
            .map { |v| [v.description_or_email, "valuator_#{v.id}"] }
    end

    def investment_tags_select_options(context)
      budget.investments.tags_on(context).order(:name).pluck(:name)
    end
end
