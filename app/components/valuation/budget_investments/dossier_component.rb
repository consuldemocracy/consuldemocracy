class Valuation::BudgetInvestments::DossierComponent < ApplicationComponent
  attr_reader :investment
  use_helpers :sanitize_and_auto_link

  def initialize(investment)
    @investment = investment
  end

  private

    def budget
      investment.budget
    end

    def explanation_field(field)
      simple_format_no_tags_no_sanitize(sanitize_and_auto_link(field)) if field.present?
    end

    def simple_format_no_tags_no_sanitize(html)
      simple_format(html, {}, sanitize: false)
    end
end
