class Poll::Ballot < ApplicationRecord
  belongs_to :ballot_sheet, class_name: Poll::BallotSheet

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
    Budget::Ballot.where(poll_ballot: self).first
  end

  def find_investment(investment_id)
    ballot.budget.investments.where(id: investment_id).first
  end

  def not_already_added?(investment)
    ballot.lines.where(investment: investment).blank?
  end

end
