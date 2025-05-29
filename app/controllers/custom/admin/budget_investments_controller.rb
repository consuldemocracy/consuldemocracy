load Rails.root.join("app", "controllers", "admin", "budget_investments_controller.rb")
class Admin::BudgetInvestmentsController < Admin::BaseController

  private

    alias_method :consul_allowed_params, :allowed_params
    
    def allowed_params
      consul_allowed_params + [:winner]
    end
    
end
