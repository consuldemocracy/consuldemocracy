class Admin::BudgetInvestments::InvestmentsComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "admin", "budget_investments", "investments_component.rb")

class Admin::BudgetInvestments::InvestmentsComponent
  private

    def xlsx_params
      xlsx_params = params.clone.merge(format: :xlsx)
      xlsx_params = xlsx_params.to_unsafe_h.transform_keys(&:to_sym)
      xlsx_params.delete(:page)
      xlsx_params
    end
end
