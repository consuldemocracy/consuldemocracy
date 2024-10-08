class Admin::BudgetInvestments::ToggleVisibleToValuatorsComponent < ApplicationComponent
  attr_reader :investment
  use_helpers :can?
  delegate :visible_to_valuators?, to: :investment

  def initialize(investment)
    @investment = investment
  end

  private

    def action
      if visible_to_valuators?
        :hide_from_valuators
      else
        :show_to_valuators
      end
    end

    def text
      if visible_to_valuators?
        t("shared.yes")
      else
        t("shared.no")
      end
    end

    def options
      {
        "aria-label": label,
        form_class: "visible-to-valuators"
      }
    end

    def label
      t("admin.actions.show_to_valuators", name: investment.title)
    end
end
