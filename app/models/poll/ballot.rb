class Poll::Ballot < ApplicationRecord
  belongs_to :ballot_sheet

  validates :ballot_sheet_id, presence: true

  def verify
    investments.each do |investment_id|
      add_investment(investment_id)
    end
  end

  def add_investment(investment_id)
    investment = find_investment(investment_id)

    if investment.present? && not_already_added?(investment)
      ballot.add_investment(investment)
    end
  end

  def investments
    data.split(",")
  end

  def ballot
    Budget::Ballot.find_by(poll_ballot: self)
  end

  def find_investment(investment_id)
    ballot.budget.investments.find_by(id: investment_id)
  end

  def not_already_added?(investment)
    ballot.lines.where(investment: investment).blank?
  end
end
