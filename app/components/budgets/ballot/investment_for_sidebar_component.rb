class Budgets::Ballot::InvestmentForSidebarComponent < Budgets::Ballot::InvestmentComponent
  with_collection_parameter :investment
  attr_reader :investment_ids

  def initialize(investment:, investment_ids:)
    super(investment: investment)
    @investment_ids = investment_ids
  end

  private

    def list_item_id
      "#{super}_sidebar"
    end

    def investment_title
      tag.span investment.title, class: "ballot-list-title"
    end

    def delete_path
      budget_ballot_line_path(id: investment.id, investments_ids: investment_ids)
    end
end
