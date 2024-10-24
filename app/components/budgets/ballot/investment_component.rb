class Budgets::Ballot::InvestmentComponent < ApplicationComponent
  attr_reader :investment

  def initialize(investment:)
    @investment = investment
  end

  private

    def budget
      investment.budget
    end

    def list_item_id
      dom_id(investment)
    end

    def investment_title
      link_to investment.title, budget_investment_path(budget, investment)
    end

    def investment_price
      tag.span investment.formatted_price, class: "ballot-list-price" if budget.show_money?
    end

    def delete_path
      budget_ballot_line_path(budget, id: investment.id)
    end
end
