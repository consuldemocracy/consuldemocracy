require_dependency Rails.root.join("app", "controllers", "admin", "budget_investments_controller").to_s

class Admin::BudgetInvestmentsController < Admin::BaseController
  include ImageAttributes

  def budget_investment_params
    attributes = [:external_url, :heading_id, :administrator_id, :tag_list,
                  :valuation_tag_list, :incompatible, :visible_to_valuators, :selected,
                  :milestone_tag_list, answers_attributes: [:id, :text, :budget_id, :investment_id, :budget_question_id],
                  valuator_ids: [], valuator_group_ids: [],
                  image_attributes: image_attributes,
                ]
    params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
  end
end
