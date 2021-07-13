class Budgets::Investments::NewComponent < ApplicationComponent
  include Header
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def title
    safe_join([base_title, subtitle].compact, " ")
  end

  private

    def base_title
      sanitize(t("budgets.investments.form.title"))
    end

    def subtitle
      if budget.single_heading?
        tag.span t("budgets.investments.form.subtitle",
                   heading: budget.headings.first.name,
                   price: budget.formatted_heading_price(budget.headings.first))
      end
    end
end
